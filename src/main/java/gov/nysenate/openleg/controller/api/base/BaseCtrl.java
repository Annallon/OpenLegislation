package gov.nysenate.openleg.controller.api.base;

import com.google.common.collect.BoundType;
import com.google.common.collect.Range;
import com.google.common.eventbus.EventBus;
import gov.nysenate.openleg.client.response.error.ErrorCode;
import gov.nysenate.openleg.client.response.error.ErrorResponse;
import gov.nysenate.openleg.client.response.error.ViewObjectErrorResponse;
import gov.nysenate.openleg.client.view.error.InvalidParameterView;
import gov.nysenate.openleg.client.view.request.ParameterView;
import gov.nysenate.openleg.dao.base.LimitOffset;
import gov.nysenate.openleg.dao.base.SortOrder;
import gov.nysenate.openleg.model.entity.Chamber;
import gov.nysenate.openleg.model.notification.Notification;
import gov.nysenate.openleg.model.notification.NotificationType;
import gov.nysenate.openleg.model.search.SearchException;
import gov.nysenate.openleg.model.updates.UpdateType;
import gov.nysenate.openleg.util.OutputUtils;
import org.apache.catalina.connector.ClientAbortException;
import org.apache.commons.lang3.BooleanUtils;
import org.apache.commons.lang3.ObjectUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.apache.commons.lang3.math.NumberUtils;
import org.apache.shiro.authz.AuthorizationException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.context.request.WebRequest;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.*;

import static gov.nysenate.openleg.model.notification.NotificationType.REQUEST_EXCEPTION;

public abstract class BaseCtrl
{
    private static final Logger logger = LoggerFactory.getLogger(BaseCtrl.class);

    public static final String BASE_API_PATH = "/api/3";
    public static final String BASE_ADMIN_API_PATH = BASE_API_PATH + "/admin";

    /** Maximum number of results that can be requested via the query params. */
    private static final int MAX_LIMIT = 1000;

    @Autowired
    private EventBus eventBus;

    /** --- Param grabbers --- */

    /**
     * Returns a sort order extracted from the given web request parameters
     * Returns the given default sort order if no such parameter exists
     *
     * @param webRequest WebRequest
     * @param defaultSortOrder SortOrder
     * @return SortOrder
     */
    protected SortOrder getSortOrder(WebRequest webRequest, SortOrder defaultSortOrder) {
        try {
            return SortOrder.valueOf(webRequest.getParameter("order").toUpperCase());
        }
        catch (Exception ex) {
            return defaultSortOrder;
        }
    }

    /**
     * Returns a limit + offset extracted from the given web request parameters
     * Returns the given default limit offset if no such parameters exist
     *
     * @param webRequest WebRequest
     * @param defaultLimit int - The default limit to use, 0 for no limit
     * @return LimitOffset
     */
    protected LimitOffset getLimitOffset(WebRequest webRequest, int defaultLimit) {
        int limit = defaultLimit;
        int offset = 0;
        if (webRequest.getParameter("limit") != null) {
            String limitStr = webRequest.getParameter("limit");
            if (limitStr.equalsIgnoreCase("all")) {
                limit = 0;
            }
            else {
                limit = NumberUtils.toInt(limitStr, defaultLimit);
                if (limit > MAX_LIMIT) {
                    throw new InvalidRequestParamEx(limitStr, "limit", "int", "Must be <= " + MAX_LIMIT);
                }
            }
        }
        if (webRequest.getParameter("offset") != null) {
            offset = NumberUtils.toInt(webRequest.getParameter("offset"), 0);
        }
        return new LimitOffset(limit, offset);
    }

    /**
     * Attempts to parse a date request parameter
     * Throws an InvalidRequestParameterException if the parsing went wrong
     *
     * @param dateString The parameter value to be parsed
     * @param parameter The name of the parameter.  Used to generate the exception
     * @return LocalDate
     * @throws InvalidRequestParamEx
     */
    protected LocalDate parseISODate(String dateString, String parameter) {
        try {
            return LocalDate.from(DateTimeFormatter.ISO_DATE.parse(dateString));
        }
        catch (DateTimeParseException ex) {
            throw new InvalidRequestParamEx(dateString, parameter,
                "date", "ISO 8601 date formatted string e.g. 2014-10-27 for October 27, 2014");
        }
    }

    /**
     * Attempts to parse a date time request parameter
     * Throws an InvalidRequestParameterException if the parsing went wrong
     *
     * @param dateTimeString The parameter value to be parsed
     * @param parameterName The name of the parameter.  Used to generate the exception
     * @return LocalDateTime
     * @throws InvalidRequestParamEx
     */
    protected LocalDateTime parseISODateTime(String dateTimeString, String parameterName) {
        try {
            return LocalDateTime.from(DateTimeFormatter.ISO_DATE_TIME.parse(dateTimeString));
        }
        catch (DateTimeParseException ex) {
            throw new InvalidRequestParamEx(dateTimeString, parameterName,
                "date-time", "ISO 8601 date and time formatted string e.g. 2014-10-27T09:44:55 for October 27, 2014 9:44:55 AM");
        }
    }

    /**
     * Constructs a Range from the given parameters.  Throws an exception if the parameter values are invalid
     * @param lower T
     * @param upper T
     * @param fromName String
     * @param upperName String
     * @param lowerType BoundType
     * @param upperType BoundType
     * @param <T> T
     * @return Range<T>
     */
    protected <T extends Comparable> Range<T> getRange(T lower, T upper, String fromName, String upperName,
                                                                    BoundType lowerType, BoundType upperType) {
        try {
            return Range.range(lower, lowerType, upper, upperType);
        } catch (IllegalArgumentException ex) {
            String rangeString = (lowerType == BoundType.OPEN ? "(" : "[") + lower + " - " +
                    upper + (upperType == BoundType.OPEN ? ")" : "]");
            throw new InvalidRequestParamEx( rangeString, fromName + ", " + upperName, "range",
                                            "Range start must not exceed range end");
        }
    }

    protected <T extends Comparable> Range<T> getOpenRange(T lower, T upper, String fromName, String upperName) {
        return getRange(lower, upper, fromName, upperName, BoundType.OPEN, BoundType.OPEN);
    }

    protected <T extends Comparable> Range<T> getOpenClosedRange(T lower, T upper, String fromName, String upperName) {
        return getRange(lower, upper, fromName, upperName, BoundType.OPEN, BoundType.CLOSED);
    }

    protected <T extends Comparable> Range<T> getClosedOpenRange(T lower, T upper, String fromName, String upperName) {
        return getRange(lower, upper, fromName, upperName, BoundType.CLOSED, BoundType.OPEN);
    }

    protected <T extends Comparable> Range<T> getClosedRange(T lower, T upper, String fromName, String upperName) {
        return getRange(lower, upper, fromName, upperName, BoundType.CLOSED, BoundType.CLOSED);
    }

    /**
     * Extracts and parses an integer param from the given web request, throws an exception if it doesn't parse
     */
    protected int getIntegerParam(WebRequest request, String paramName) {
        String intString = request.getParameter(paramName);
        try {
            return Integer.parseInt(intString);
        } catch (NumberFormatException ex) {
            throw new InvalidRequestParamEx(intString, paramName, "integer", "integer");
        }
    }

    /**
     * An overload of getIntegerParam that returns a default int value if there is a parsing error
     * @see #getIntegerParam
     */
    protected int getIntegerParam(WebRequest request, String paramName, int defaultVal) {
        try {
            return getIntegerParam(request, paramName);
        } catch (InvalidRequestParamEx ex) {
            return defaultVal;
        }
    }

    /**
     * Parses the specified query param as a boolean or returns the default value if the param is not set.
     *
     * @param param WebRequest
     * @param defaultVal boolean
     * @return boolean
     */
    protected boolean getBooleanParam(WebRequest request, String param, boolean defaultVal) {
        return (request.getParameter(param) != null) ? BooleanUtils.toBoolean(request.getParameter(param)) : defaultVal;
    }

    /**
     * Parses the update type from the request parameters. Defaults to the 'processed' date.
     *
     * @param request WebRequest
     * @return UpdateType
     */
    protected UpdateType getUpdateTypeFromParam(WebRequest request) {
        String type = request.getParameter("type");
        return (type == null || type.equalsIgnoreCase("processed")) ? UpdateType.PROCESSED_DATE
                                                                    : UpdateType.PUBLISHED_DATE;
    }

    /**
     * Attempts to parse a NotificationType from the provided string.
     * @throws gov.nysenate.openleg.controller.api.base.InvalidRequestParamEx if the text does not match a NotificationType
     */
    protected NotificationType getNotificationTypeFromString(String text) {
        try {
            return NotificationType.getValue(text);
        } catch (IllegalArgumentException e) {
            throw new InvalidRequestParamEx(text, "type", "String",
                    NotificationType.getAllNotificationTypes().stream()
                            .map(NotificationType::toString)
                            .reduce("", (a, b) -> a + "|" + b));
        }
    }

    protected <T extends Enum<T>> T getEnumParameter(Class<T> enumType, String paramName, String paramValue) {
        try {
            return T.valueOf(enumType, StringUtils.upperCase(paramValue));
        } catch (IllegalArgumentException | NullPointerException ex) {
            throw new InvalidRequestParamEx(paramValue, paramName, "string",
                    Arrays.asList(enumType.getEnumConstants()).stream()
                            .map(Enum::toString)
                            .reduce("", (a, b) -> (StringUtils.isNotBlank(a) ? a + "|" : "") + b));
        }
    }

    protected <T extends Enum<T>> T getEnumParameter(Class<T> enumType, String paramName, String paramValue, T defaultValue) {
        try {
            return getEnumParameter(enumType, paramName, paramValue);
        } catch (InvalidRequestParamEx ex) {
            return defaultValue;
        }
    }

    /**
     * Checks that the given parameter names are present in the provided web request
     * @param request WebRequest
     * @param paramNamesAndTypes Map<String, String> - A map of parameter names to their type
     * @throws MissingServletRequestParameterException if a parameter is not present in the web request
     */
    protected void requireParameters(WebRequest request, Map<String, String> paramNamesAndTypes)
            throws MissingServletRequestParameterException {
        for (String paramName : paramNamesAndTypes.keySet()) {
            if (request.getParameter(paramName) == null) {
                throw new MissingServletRequestParameterException(paramName, paramNamesAndTypes.get(paramName));
            }
        }
    }

    /**
     * A convenient overload of requireParameters that constructs the paramNamesAndTypes map from an array
     *  in the format [name1, type1, name2, type2, ... ]
     *  @see #requireParameters
     */
    protected void requireParameters(WebRequest request, String... paramNamesAndTypes)
            throws MissingServletRequestParameterException {
        Map<String, String> paramMap = new HashMap<>();
        for (int i = 0; i < paramNamesAndTypes.length / 2; i++) {
            paramMap.put(paramNamesAndTypes[2 * i], paramNamesAndTypes[2 * i + 1]);
        }
        requireParameters(request, paramMap);
    }

    /** --- Generic Exception Handlers --- */

    @ExceptionHandler(Exception.class)
    @ResponseStatus(value = HttpStatus.INTERNAL_SERVER_ERROR)
    protected ErrorResponse handleUnknownError(Exception ex) {
        logger.error("Caught unhandled servlet exception:\n{}", ExceptionUtils.getStackTrace(ex));
        pushExceptionNotification(ex);
        return new ErrorResponse(ErrorCode.UNKNOWN_ERROR);
    }

    @ExceptionHandler(InvalidRequestParamEx.class)
    @ResponseStatus(value = HttpStatus.BAD_REQUEST)
    protected ErrorResponse handleInvalidRequestParameterException(InvalidRequestParamEx ex) {
        logger.debug(ExceptionUtils.getStackTrace(ex));
        return new ViewObjectErrorResponse(ErrorCode.INVALID_ARGUMENTS, new InvalidParameterView(ex));
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    @ResponseStatus(value = HttpStatus.BAD_REQUEST)
    protected ErrorResponse handleMissingParameterException(MissingServletRequestParameterException ex) {
        logger.debug(ExceptionUtils.getStackTrace(ex));
        return new ViewObjectErrorResponse(ErrorCode.MISSING_PARAMETERS,
            new ParameterView(ex.getParameterName(), ex.getParameterType()));
    }

    @ExceptionHandler(SearchException.class)
    @ResponseStatus(value = HttpStatus.BAD_REQUEST)
    public ViewObjectErrorResponse searchExceptionHandler(SearchException ex) {
        logger.debug("Search Exception!", ex);
        return new ViewObjectErrorResponse(ErrorCode.SEARCH_ERROR, ex.getMessage());
    }

    @ExceptionHandler(AuthorizationException.class)
    @ResponseStatus(value = HttpStatus.UNAUTHORIZED)
    public ErrorResponse handleUnauthenticatedException(AuthorizationException ex) {
        logger.debug("Authorization Exception! {}", ex.getMessage());
        return new ErrorResponse(ErrorCode.UNAUTHORIZED);
    }

    @ResponseStatus(value = HttpStatus.REQUEST_TIMEOUT, reason = "Client abort")
    @ExceptionHandler(ClientAbortException.class)
    public void handleClientAbortException(ClientAbortException ex) {
        logger.debug("Client aborted");
        // Do Nothing
    }

    private void pushExceptionNotification(Exception ex) {
        LocalDateTime occurred = LocalDateTime.now();
        String summary = "Request Exception at " + occurred + " - " + ExceptionUtils.getStackFrames(ex)[0];
        String message = "The following exception was thrown while handling a request at " + occurred + ":\n\n"
                + ExceptionUtils.getStackTrace(ex);
        Notification notification = new Notification(REQUEST_EXCEPTION, occurred, summary, message);

        eventBus.post(notification);
    }
}