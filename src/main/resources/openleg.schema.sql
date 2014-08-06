--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: master; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA master;


ALTER SCHEMA master OWNER TO postgres;

SET search_path = master, pg_catalog;

--
-- Name: cmt; Type: TYPE; Schema: master; Owner: postgres
--

CREATE TYPE cmt AS ENUM (
    'chair_person',
    'vicechair',
    'member'
);


ALTER TYPE master.cmt OWNER TO postgres;

--
-- Name: committee_member_title; Type: TYPE; Schema: master; Owner: postgres
--

CREATE TYPE committee_member_title AS ENUM (
    'chair_person',
    'vice_chair',
    'member'
);


ALTER TYPE master.committee_member_title OWNER TO postgres;

--
-- Name: sobi_fragment_type; Type: TYPE; Schema: master; Owner: postgres
--

CREATE TYPE sobi_fragment_type AS ENUM (
    'bill',
    'agenda',
    'agenda_vote',
    'calendar',
    'calendar_active',
    'committee',
    'annotation'
);


ALTER TYPE master.sobi_fragment_type OWNER TO postgres;

--
-- Name: veto_type; Type: TYPE; Schema: master; Owner: postgres
--

CREATE TYPE veto_type AS ENUM (
    'standard',
    'line_item'
);


ALTER TYPE master.veto_type OWNER TO postgres;

--
-- Name: vote_code; Type: TYPE; Schema: master; Owner: postgres
--

CREATE TYPE vote_code AS ENUM (
    'aye',
    'nay',
    'exc',
    'abs',
    'abd',
    'ayewr'
);


ALTER TYPE master.vote_code OWNER TO postgres;

--
-- Name: vote_type; Type: TYPE; Schema: master; Owner: postgres
--

CREATE TYPE vote_type AS ENUM (
    'floor',
    'committee'
);


ALTER TYPE master.vote_type OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- Name: chamber; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE chamber AS ENUM (
    'assembly',
    'senate'
);


ALTER TYPE public.chamber OWNER TO postgres;

--
-- Name: committee_member_title; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE committee_member_title AS ENUM (
    'chair_person',
    'vice_chair',
    'member'
);


ALTER TYPE public.committee_member_title OWNER TO postgres;

SET search_path = master, pg_catalog;

--
-- Name: data_updated(); Type: FUNCTION; Schema: master; Owner: postgres
--

CREATE FUNCTION data_updated() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 IF tg_op = 'UPDATE' THEN
   INSERT INTO master.sobi_change_log(table_name, action, key, data, modified_date_time, sobi_fragment_id)
   VALUES (tg_table_name::text, 'u', hstore(ARRAY['print_no', NEW.print_no, 'session_year', NEW.session_year::character varying]), hstore(new.*) - hstore(old.*), current_timestamp, NEW.last_fragment_file_name	);
   RETURN NEW;
 ELSIF tg_op = 'DELETE' THEN
   INSERT INTO master.sobi_change_log(table_name, action, key, data, modified_date_time)
   VALUES (tg_table_name::text, 'd', hstore(ARRAY['print_no', OLD.print_no, 'session_year', OLD.session_year::character varying]), hstore(old.*), current_timestamp);
   RETURN OLD;			
 ELSIF tg_op = 'INSERT' THEN
   INSERT INTO master.sobi_change_log(table_name, action,key, data, modified_date_time, sobi_fragment_id)
   VALUES (tg_table_name::text, 'i', hstore(ARRAY['print_no', NEW.print_no, 'session_year', NEW.session_year::character varying]), hstore(new.*), current_timestamp, NEW.last_fragment_file_name);
   RETURN NEW;			
 END IF;
END;
$$;


ALTER FUNCTION master.data_updated() OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- Name: write_muwhahah(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION write_muwhahah() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
  NEW.text := 'muwhahahahha';
  RETURN NEW;
END$$;


ALTER FUNCTION public.write_muwhahah() OWNER TO postgres;

SET search_path = master, pg_catalog;

--
-- Name: openleg_fts_config; Type: TEXT SEARCH CONFIGURATION; Schema: master; Owner: postgres
--

CREATE TEXT SEARCH CONFIGURATION openleg_fts_config (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR asciiword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR word WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR hword_part WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR hword_asciipart WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR asciihword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR hword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION openleg_fts_config
    ADD MAPPING FOR uint WITH simple;


ALTER TEXT SEARCH CONFIGURATION master.openleg_fts_config OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: agenda; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE agenda (
    agenda_no smallint NOT NULL,
    year smallint NOT NULL,
    published_date_time timestamp without time zone,
    modified_date_time timestamp without time zone,
    created_date_time timestamp without time zone DEFAULT now() NOT NULL,
    last_fragment_id text
);


ALTER TABLE master.agenda OWNER TO postgres;

--
-- Name: TABLE agenda; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE agenda IS 'Listing of all senate agendas';


--
-- Name: agenda_info_addendum; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE agenda_info_addendum (
    agenda_no smallint NOT NULL,
    year smallint NOT NULL,
    addendum_id text NOT NULL,
    modified_date_time timestamp without time zone,
    published_date_time timestamp without time zone,
    created_date_time timestamp without time zone DEFAULT now() NOT NULL,
    last_fragment_id text,
    week_of date
);


ALTER TABLE master.agenda_info_addendum OWNER TO postgres;

--
-- Name: TABLE agenda_info_addendum; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE agenda_info_addendum IS 'Info addendum listings for agendas ';


--
-- Name: agenda_info_committee; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE agenda_info_committee (
    id integer NOT NULL,
    agenda_no smallint NOT NULL,
    year smallint NOT NULL,
    addendum_id text NOT NULL,
    committee_name public.citext NOT NULL,
    committee_chamber public.chamber NOT NULL,
    chair text,
    location text,
    meeting_date_time timestamp without time zone NOT NULL,
    notes text,
    last_fragment_id text,
    created_date_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE master.agenda_info_committee OWNER TO postgres;

--
-- Name: TABLE agenda_info_committee; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE agenda_info_committee IS 'Committee info sent via the info addenda';


--
-- Name: agenda_info_committee_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE agenda_info_committee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.agenda_info_committee_id_seq OWNER TO postgres;

--
-- Name: agenda_info_committee_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE agenda_info_committee_id_seq OWNED BY agenda_info_committee.id;


--
-- Name: agenda_info_committee_item; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE agenda_info_committee_item (
    id integer NOT NULL,
    info_committee_id integer NOT NULL,
    bill_print_no text NOT NULL,
    bill_session_year smallint NOT NULL,
    bill_amend_version character(1) NOT NULL,
    message text,
    created_date_time timestamp without time zone DEFAULT now() NOT NULL,
    last_fragment_id text
);


ALTER TABLE master.agenda_info_committee_item OWNER TO postgres;

--
-- Name: TABLE agenda_info_committee_item; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE agenda_info_committee_item IS 'Bills on the agenda for a given committee info';


--
-- Name: agenda_info_committee_item_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE agenda_info_committee_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.agenda_info_committee_item_id_seq OWNER TO postgres;

--
-- Name: agenda_info_committee_item_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE agenda_info_committee_item_id_seq OWNED BY agenda_info_committee_item.id;


--
-- Name: agenda_vote_addendum; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE agenda_vote_addendum (
    agenda_no smallint NOT NULL,
    year smallint NOT NULL,
    addendum_id character varying NOT NULL,
    modified_date_time timestamp without time zone,
    published_date_time timestamp without time zone,
    created_date_time timestamp without time zone DEFAULT now() NOT NULL,
    last_fragment_id text
);


ALTER TABLE master.agenda_vote_addendum OWNER TO postgres;

--
-- Name: TABLE agenda_vote_addendum; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE agenda_vote_addendum IS 'Vote addendum listings for agendas';


--
-- Name: agenda_vote_commitee_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE agenda_vote_commitee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.agenda_vote_commitee_id_seq OWNER TO postgres;

--
-- Name: agenda_vote_committee; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE agenda_vote_committee (
    id integer DEFAULT nextval('agenda_vote_commitee_id_seq'::regclass) NOT NULL,
    agenda_no smallint NOT NULL,
    year smallint NOT NULL,
    addendum_id text NOT NULL,
    committee_name public.citext NOT NULL,
    committee_chamber public.chamber NOT NULL,
    chair text,
    meeting_date_time timestamp without time zone,
    last_fragment_id text,
    created_date_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE master.agenda_vote_committee OWNER TO postgres;

--
-- Name: TABLE agenda_vote_committee; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE agenda_vote_committee IS 'Committee info sent via the vote addenda';


--
-- Name: agenda_vote_committee_attend; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE agenda_vote_committee_attend (
    id integer NOT NULL,
    vote_committee_id integer,
    member_id integer NOT NULL,
    session_year smallint NOT NULL,
    lbdc_short_name text NOT NULL,
    rank smallint NOT NULL,
    party text,
    attend_status text,
    created_date_time timestamp without time zone DEFAULT now() NOT NULL,
    last_fragment_id text
);


ALTER TABLE master.agenda_vote_committee_attend OWNER TO postgres;

--
-- Name: TABLE agenda_vote_committee_attend; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE agenda_vote_committee_attend IS 'Attendance roll for committee vote meeting';


--
-- Name: agenda_vote_committee_attend_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE agenda_vote_committee_attend_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.agenda_vote_committee_attend_id_seq OWNER TO postgres;

--
-- Name: agenda_vote_committee_attend_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE agenda_vote_committee_attend_id_seq OWNED BY agenda_vote_committee_attend.id;


--
-- Name: agenda_vote_committee_vote; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE agenda_vote_committee_vote (
    id integer NOT NULL,
    vote_committee_id integer,
    vote_action text NOT NULL,
    vote_info_id integer,
    refer_committee_name public.citext,
    refer_committee_chamber public.chamber,
    with_amendment boolean DEFAULT false NOT NULL,
    created_date_time timestamp without time zone DEFAULT now() NOT NULL,
    last_fragment_id text
);


ALTER TABLE master.agenda_vote_committee_vote OWNER TO postgres;

--
-- Name: TABLE agenda_vote_committee_vote; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE agenda_vote_committee_vote IS 'List of committee vote details';


--
-- Name: agenda_vote_committee_vote_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE agenda_vote_committee_vote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.agenda_vote_committee_vote_id_seq OWNER TO postgres;

--
-- Name: agenda_vote_committee_vote_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE agenda_vote_committee_vote_id_seq OWNED BY agenda_vote_committee_vote.id;


--
-- Name: bill; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE bill (
    print_no text NOT NULL,
    session_year smallint NOT NULL,
    title text,
    law_section text,
    summary text,
    active_version character(1) NOT NULL,
    active_year integer,
    modified_date_time timestamp without time zone,
    published_date_time timestamp without time zone,
    last_fragment_id text,
    law_code text,
    created_date_time timestamp without time zone DEFAULT now(),
    program_info text
);


ALTER TABLE master.bill OWNER TO postgres;

--
-- Name: TABLE bill; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE bill IS 'General information about a bill';


--
-- Name: COLUMN bill.print_no; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN bill.print_no IS 'The base print no (e.g S1234)';


--
-- Name: COLUMN bill.session_year; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN bill.session_year IS 'The session year this bill was active in';


--
-- Name: COLUMN bill.title; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN bill.title IS 'The title of the bill';


--
-- Name: COLUMN bill.law_section; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN bill.law_section IS 'The section of law this bill affects';


--
-- Name: COLUMN bill.summary; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN bill.summary IS 'A summary of the bill';


--
-- Name: COLUMN bill.active_version; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN bill.active_version IS 'The amendment version that is currently active';


--
-- Name: COLUMN bill.active_year; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN bill.active_year IS 'The actual year the bill was introduced in';


--
-- Name: COLUMN bill.modified_date_time; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN bill.modified_date_time IS 'Last date/time when this bill was modified';


--
-- Name: COLUMN bill.published_date_time; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN bill.published_date_time IS 'Date/time when this bill became published';


--
-- Name: COLUMN bill.last_fragment_id; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN bill.last_fragment_id IS 'Reference to the last sobi fragment that caused an update';


--
-- Name: COLUMN bill.law_code; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN bill.law_code IS 'Specifies the sections/chapters of laws that are affected';


--
-- Name: COLUMN bill.created_date_time; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN bill.created_date_time IS 'The date/time when this bill record was inserted';


--
-- Name: COLUMN bill.program_info; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN bill.program_info IS 'The program this bill was introduced for ';


--
-- Name: bill_amendment; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE bill_amendment (
    bill_print_no text NOT NULL,
    bill_session_year smallint NOT NULL,
    version character(1) NOT NULL,
    sponsor_memo text,
    act_clause text,
    full_text text,
    stricken boolean DEFAULT false,
    uni_bill boolean DEFAULT false,
    modified_date_time timestamp without time zone,
    published_date_time timestamp without time zone,
    last_fragment_id text,
    current_committee_name text,
    current_committee_action timestamp without time zone
);


ALTER TABLE master.bill_amendment OWNER TO postgres;

--
-- Name: TABLE bill_amendment; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE bill_amendment IS 'Information specific to a bill amendment';


--
-- Name: bill_amendment_action; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE bill_amendment_action (
    bill_print_no text NOT NULL,
    bill_session_year smallint NOT NULL,
    bill_amend_version character(1) NOT NULL,
    effect_date date,
    text text,
    modified_date_time timestamp without time zone,
    published_date_time timestamp without time zone,
    last_fragment_id text,
    sequence_no smallint NOT NULL,
    chamber public.chamber NOT NULL
);


ALTER TABLE master.bill_amendment_action OWNER TO postgres;

--
-- Name: TABLE bill_amendment_action; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE bill_amendment_action IS 'Actions that have been taken on an amendment';


--
-- Name: bill_amendment_cosponsor; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE bill_amendment_cosponsor (
    bill_print_no text NOT NULL,
    bill_session_year smallint NOT NULL,
    bill_amend_version character(1) NOT NULL,
    member_id integer NOT NULL,
    sequence_no smallint NOT NULL
);


ALTER TABLE master.bill_amendment_cosponsor OWNER TO postgres;

--
-- Name: TABLE bill_amendment_cosponsor; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE bill_amendment_cosponsor IS 'Listing of co-sponsors for an amendment';


--
-- Name: bill_amendment_multi_sponsor; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE bill_amendment_multi_sponsor (
    bill_print_no text NOT NULL,
    bill_session_year smallint NOT NULL,
    bill_amend_version character(1) NOT NULL,
    member_id integer NOT NULL,
    sequence_no smallint NOT NULL
);


ALTER TABLE master.bill_amendment_multi_sponsor OWNER TO postgres;

--
-- Name: TABLE bill_amendment_multi_sponsor; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE bill_amendment_multi_sponsor IS 'Listing of multi-sponsors for a bill';


--
-- Name: bill_amendment_same_as; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE bill_amendment_same_as (
    bill_print_no text,
    bill_session_year smallint,
    bill_amend_version character(1),
    same_as_bill_print_no text,
    same_as_session_year smallint,
    same_as_amend_version character(1)
);


ALTER TABLE master.bill_amendment_same_as OWNER TO postgres;

--
-- Name: TABLE bill_amendment_same_as; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE bill_amendment_same_as IS 'Same as bills for an amendment';


--
-- Name: bill_amendment_vote_info; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE bill_amendment_vote_info (
    bill_print_no text NOT NULL,
    bill_session_year smallint NOT NULL,
    bill_amend_version character(1) NOT NULL,
    vote_date timestamp without time zone NOT NULL,
    sequence_no smallint,
    id integer NOT NULL,
    published_date_time timestamp without time zone,
    modified_date_time timestamp without time zone,
    vote_type vote_type NOT NULL
);


ALTER TABLE master.bill_amendment_vote_info OWNER TO postgres;

--
-- Name: TABLE bill_amendment_vote_info; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE bill_amendment_vote_info IS 'Contains basic info about votes that have been taken on a bill.';


--
-- Name: COLUMN bill_amendment_vote_info.bill_print_no; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN bill_amendment_vote_info.bill_print_no IS 'The print no of the bill that was voted on';


--
-- Name: COLUMN bill_amendment_vote_info.bill_session_year; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN bill_amendment_vote_info.bill_session_year IS 'The session year of the bill that was voted on';


--
-- Name: COLUMN bill_amendment_vote_info.bill_amend_version; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN bill_amendment_vote_info.bill_amend_version IS 'The amendment version of the bill that was voted on';


--
-- Name: bill_amendment_vote_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE bill_amendment_vote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.bill_amendment_vote_id_seq OWNER TO postgres;

--
-- Name: bill_amendment_vote_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE bill_amendment_vote_id_seq OWNED BY bill_amendment_vote_info.id;


--
-- Name: bill_amendment_vote_roll; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE bill_amendment_vote_roll (
    vote_id integer NOT NULL,
    member_id integer NOT NULL,
    member_short_name text NOT NULL,
    session_year smallint NOT NULL,
    vote_code vote_code NOT NULL
);


ALTER TABLE master.bill_amendment_vote_roll OWNER TO postgres;

--
-- Name: TABLE bill_amendment_vote_roll; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE bill_amendment_vote_roll IS 'Contains a list of member votes';


--
-- Name: bill_committee; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE bill_committee (
    bill_print_no text NOT NULL,
    bill_session_year smallint NOT NULL,
    committee_name public.citext NOT NULL,
    committee_chamber public.chamber NOT NULL,
    action_date timestamp without time zone NOT NULL
);


ALTER TABLE master.bill_committee OWNER TO postgres;

--
-- Name: TABLE bill_committee; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE bill_committee IS 'Mapping of bills to committees';


--
-- Name: COLUMN bill_committee.action_date; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN bill_committee.action_date IS 'The date that the committee acted on the bill';


--
-- Name: bill_previous_version; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE bill_previous_version (
    bill_print_no text NOT NULL,
    bill_session_year smallint NOT NULL,
    prev_bill_print_no text,
    prev_bill_session_year smallint,
    prev_amend_version text
);


ALTER TABLE master.bill_previous_version OWNER TO postgres;

--
-- Name: TABLE bill_previous_version; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE bill_previous_version IS 'Listing of this bill in previous session years';


--
-- Name: bill_sponsor; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE bill_sponsor (
    bill_print_no text NOT NULL,
    bill_session_year smallint NOT NULL,
    member_id integer,
    budget_bill boolean DEFAULT false,
    rules_sponsor boolean DEFAULT false
);


ALTER TABLE master.bill_sponsor OWNER TO postgres;

--
-- Name: TABLE bill_sponsor; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE bill_sponsor IS 'Mapping of bill to sponsor';


--
-- Name: bill_sponsor_additional; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE bill_sponsor_additional (
    bill_print_no text NOT NULL,
    bill_session_year smallint NOT NULL,
    member_id integer NOT NULL,
    sequence_no smallint
);


ALTER TABLE master.bill_sponsor_additional OWNER TO postgres;

--
-- Name: TABLE bill_sponsor_additional; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE bill_sponsor_additional IS 'Contains additional sponsor mappings for special cases';


--
-- Name: bill_veto; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE bill_veto (
    veto_number integer NOT NULL,
    year integer NOT NULL,
    bill_print_no text NOT NULL,
    session_year integer NOT NULL,
    page integer,
    line_start integer,
    line_end integer,
    chapter integer,
    signer text,
    date date,
    memo_text text NOT NULL,
    type veto_type NOT NULL,
    modified_date_time timestamp without time zone NOT NULL,
    published_date_time timestamp without time zone NOT NULL,
    created_date_time timestamp without time zone DEFAULT now() NOT NULL,
    last_fragment_id text
);


ALTER TABLE master.bill_veto OWNER TO postgres;

--
-- Name: bill_veto_year_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE bill_veto_year_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.bill_veto_year_seq OWNER TO postgres;

--
-- Name: calendar; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE calendar (
    calendar_no integer NOT NULL,
    year smallint NOT NULL,
    last_fragment_id text,
    modified_date_time timestamp without time zone,
    published_date_time timestamp without time zone,
    created_date_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE master.calendar OWNER TO postgres;

--
-- Name: TABLE calendar; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE calendar IS 'Calendar listings ';


--
-- Name: COLUMN calendar.calendar_no; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN calendar.calendar_no IS 'Calendar number for a session day';


--
-- Name: COLUMN calendar.year; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN calendar.year IS 'The year for this calendar';


--
-- Name: calendar_active_list; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE calendar_active_list (
    id integer NOT NULL,
    sequence_no smallint,
    calendar_no smallint,
    calendar_year smallint,
    calendar_date date,
    release_date_time timestamp without time zone,
    last_fragment_id text,
    created_date_time timestamp without time zone DEFAULT now() NOT NULL,
    modified_date_time timestamp without time zone,
    published_date_time timestamp without time zone,
    notes text
);


ALTER TABLE master.calendar_active_list OWNER TO postgres;

--
-- Name: TABLE calendar_active_list; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE calendar_active_list IS 'Listing of all calendar active lists';


--
-- Name: calendar_active_list_entry; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE calendar_active_list_entry (
    calendar_active_list_id smallint NOT NULL,
    bill_calendar_no smallint NOT NULL,
    bill_print_no text,
    bill_amend_version character(1),
    bill_session_year smallint,
    created_date_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE master.calendar_active_list_entry OWNER TO postgres;

--
-- Name: TABLE calendar_active_list_entry; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE calendar_active_list_entry IS 'Entries for each calendar active list';


--
-- Name: calendar_active_list_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE calendar_active_list_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.calendar_active_list_id_seq OWNER TO postgres;

--
-- Name: calendar_active_list_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE calendar_active_list_id_seq OWNED BY calendar_active_list.id;


--
-- Name: calendar_supplemental; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE calendar_supplemental (
    id integer NOT NULL,
    calendar_no smallint NOT NULL,
    calendar_year smallint NOT NULL,
    sup_version text NOT NULL,
    calendar_date date,
    release_date_time timestamp without time zone,
    last_fragment_id text,
    modified_date_time timestamp without time zone,
    published_date_time timestamp without time zone,
    created_date_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE master.calendar_supplemental OWNER TO postgres;

--
-- Name: TABLE calendar_supplemental; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE calendar_supplemental IS 'Calendar entries are published through supplementals';


--
-- Name: calendar_supplemental_entry; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE calendar_supplemental_entry (
    id integer NOT NULL,
    calendar_sup_id integer,
    section_code smallint,
    bill_calendar_no smallint,
    bill_print_no text,
    bill_amend_version character(1),
    bill_session_year smallint,
    sub_bill_print_no text,
    sub_bill_amend_version character(1),
    sub_bill_session_year smallint,
    high boolean,
    created_date_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE master.calendar_supplemental_entry OWNER TO postgres;

--
-- Name: TABLE calendar_supplemental_entry; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE calendar_supplemental_entry IS 'These entries indentify bills that have been added to a calendar';


--
-- Name: COLUMN calendar_supplemental_entry.sub_bill_print_no; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN calendar_supplemental_entry.sub_bill_print_no IS 'The substituted bill''s print no, null if not substituted.';


--
-- Name: COLUMN calendar_supplemental_entry.sub_bill_amend_version; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN calendar_supplemental_entry.sub_bill_amend_version IS 'The substituted bill''s amendment version, null if not substituted.';


--
-- Name: COLUMN calendar_supplemental_entry.sub_bill_session_year; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN calendar_supplemental_entry.sub_bill_session_year IS 'The substituted bill''s session year, null if not substituted.';


--
-- Name: COLUMN calendar_supplemental_entry.high; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN calendar_supplemental_entry.high IS 'True if bill has not yet properly aged';


--
-- Name: calendar_supplemental_entry_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE calendar_supplemental_entry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.calendar_supplemental_entry_id_seq OWNER TO postgres;

--
-- Name: calendar_supplemental_entry_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE calendar_supplemental_entry_id_seq OWNED BY calendar_supplemental_entry.id;


--
-- Name: calendar_supplemental_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE calendar_supplemental_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.calendar_supplemental_id_seq OWNER TO postgres;

--
-- Name: calendar_supplemental_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE calendar_supplemental_id_seq OWNED BY calendar_supplemental.id;


--
-- Name: committee; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE committee (
    name public.citext NOT NULL,
    id integer NOT NULL,
    current_version timestamp without time zone DEFAULT '-infinity'::timestamp without time zone NOT NULL,
    chamber public.chamber NOT NULL,
    current_session integer DEFAULT 0 NOT NULL,
    full_name text
);


ALTER TABLE master.committee OWNER TO postgres;

--
-- Name: TABLE committee; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE committee IS 'Basic committee information for both senate and assembly';


--
-- Name: COLUMN committee.full_name; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN committee.full_name IS 'The full name of the committee, may be different from what LBDC uses.';


--
-- Name: committee_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE committee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.committee_id_seq OWNER TO postgres;

--
-- Name: committee_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE committee_id_seq OWNED BY committee.id;


--
-- Name: committee_member; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE committee_member (
    majority boolean NOT NULL,
    id integer NOT NULL,
    sequence_no integer NOT NULL,
    title public.committee_member_title DEFAULT 'member'::public.committee_member_title NOT NULL,
    committee_name public.citext NOT NULL,
    version_created timestamp without time zone NOT NULL,
    session_year integer NOT NULL,
    member_id integer NOT NULL,
    chamber public.chamber NOT NULL
);


ALTER TABLE master.committee_member OWNER TO postgres;

--
-- Name: TABLE committee_member; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE committee_member IS 'Membership details for committees';


--
-- Name: COLUMN committee_member.majority; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN committee_member.majority IS 'true = Majority, false = Minority';


--
-- Name: committee_member_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE committee_member_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.committee_member_id_seq OWNER TO postgres;

--
-- Name: committee_member_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE committee_member_id_seq OWNED BY committee_member.id;


--
-- Name: committee_version; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE committee_version (
    id integer NOT NULL,
    location text,
    meetday text,
    meetaltweek boolean,
    meetaltweektext text,
    meettime time without time zone,
    session_year integer NOT NULL,
    created timestamp without time zone NOT NULL,
    reformed timestamp without time zone DEFAULT 'infinity'::timestamp without time zone NOT NULL,
    committee_name public.citext NOT NULL,
    chamber public.chamber NOT NULL
);


ALTER TABLE master.committee_version OWNER TO postgres;

--
-- Name: TABLE committee_version; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE committee_version IS 'Committee details';


--
-- Name: COLUMN committee_version.created; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN committee_version.created IS 'The date that this version of the committee was created';


--
-- Name: COLUMN committee_version.reformed; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN committee_version.reformed IS 'The date that this version of the committee was reformed';


--
-- Name: committee_version_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE committee_version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.committee_version_id_seq OWNER TO postgres;

--
-- Name: committee_version_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE committee_version_id_seq OWNED BY committee_version.id;


--
-- Name: committee_version_session_year_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE committee_version_session_year_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.committee_version_session_year_seq OWNER TO postgres;

--
-- Name: committee_version_session_year_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE committee_version_session_year_seq OWNED BY committee_version.session_year;


--
-- Name: sobi_fragment; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE sobi_fragment (
    sobi_file_name text NOT NULL,
    fragment_id text NOT NULL,
    published_date_time timestamp without time zone,
    fragment_type public.citext NOT NULL,
    text text,
    sequence_no smallint NOT NULL,
    processed_count smallint DEFAULT 0 NOT NULL,
    processed_date_time timestamp without time zone,
    staged_date_time timestamp without time zone DEFAULT now() NOT NULL,
    pending_processing boolean NOT NULL
);


ALTER TABLE master.sobi_fragment OWNER TO postgres;

--
-- Name: TABLE sobi_fragment; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE sobi_fragment IS 'Listing of all Sobi fragments which are extracted from Sobi files.';


--
-- Name: COLUMN sobi_fragment.sobi_file_name; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN sobi_fragment.sobi_file_name IS 'The name of the originating Sobi file';


--
-- Name: COLUMN sobi_fragment.fragment_id; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN sobi_fragment.fragment_id IS 'A unique id for this fragment';


--
-- Name: COLUMN sobi_fragment.published_date_time; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN sobi_fragment.published_date_time IS 'The date this fragment was published';


--
-- Name: COLUMN sobi_fragment.fragment_type; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN sobi_fragment.fragment_type IS 'The type of data this fragment contains';


--
-- Name: COLUMN sobi_fragment.text; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN sobi_fragment.text IS 'The text body of the fragment';


--
-- Name: COLUMN sobi_fragment.sequence_no; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN sobi_fragment.sequence_no IS 'Preserves the order in which fragments are found in a Sobi file';


--
-- Name: COLUMN sobi_fragment.processed_count; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN sobi_fragment.processed_count IS 'The number of times this fragment has been processed';


--
-- Name: COLUMN sobi_fragment.processed_date_time; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN sobi_fragment.processed_date_time IS 'The last date/time this fragment was processed';


--
-- Name: COLUMN sobi_fragment.staged_date_time; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN sobi_fragment.staged_date_time IS 'The date/time when this fragment was recorded into the database';


--
-- Name: COLUMN sobi_fragment.pending_processing; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN sobi_fragment.pending_processing IS 'Indicates if the fragment is waiting to be processed';


--
-- Name: psf; Type: VIEW; Schema: master; Owner: postgres
--

CREATE VIEW psf AS
 SELECT sobi_fragment.sobi_file_name,
    sobi_fragment.fragment_id,
    sobi_fragment.published_date_time,
    sobi_fragment.fragment_type,
    sobi_fragment.text,
    sobi_fragment.sequence_no,
    sobi_fragment.processed_count,
    sobi_fragment.processed_date_time,
    sobi_fragment.staged_date_time,
    sobi_fragment.pending_processing
   FROM sobi_fragment
  WHERE (sobi_fragment.pending_processing = true);


ALTER TABLE master.psf OWNER TO postgres;

--
-- Name: VIEW psf; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON VIEW psf IS 'Pending Sobi Fragments';


--
-- Name: sobi_change_log; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE sobi_change_log (
    id integer NOT NULL,
    table_name text NOT NULL,
    action text NOT NULL,
    key public.hstore,
    data public.hstore,
    modified_date_time timestamp without time zone NOT NULL,
    sobi_fragment_id text
);


ALTER TABLE master.sobi_change_log OWNER TO postgres;

--
-- Name: TABLE sobi_change_log; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE sobi_change_log IS 'Change log for all entities that utilize Sobi files as the primary data source';


--
-- Name: sobi_change_log_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE sobi_change_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.sobi_change_log_id_seq OWNER TO postgres;

--
-- Name: sobi_change_log_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE sobi_change_log_id_seq OWNED BY sobi_change_log.id;


--
-- Name: sobi_file; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE sobi_file (
    file_name text NOT NULL,
    published_date_time timestamp without time zone NOT NULL,
    staged_date_time timestamp without time zone DEFAULT now() NOT NULL,
    encoding text,
    archived boolean DEFAULT false NOT NULL
);


ALTER TABLE master.sobi_file OWNER TO postgres;

--
-- Name: TABLE sobi_file; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON TABLE sobi_file IS 'Listing of all Sobi files';


--
-- Name: COLUMN sobi_file.file_name; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN sobi_file.file_name IS 'The name of the sobi file';


--
-- Name: COLUMN sobi_file.published_date_time; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN sobi_file.published_date_time IS 'The published date which is typically derived from the file name';


--
-- Name: COLUMN sobi_file.staged_date_time; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN sobi_file.staged_date_time IS 'The date/time when this file was recorded into the database';


--
-- Name: COLUMN sobi_file.encoding; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN sobi_file.encoding IS 'The character encoding used in the file';


--
-- Name: COLUMN sobi_file.archived; Type: COMMENT; Schema: master; Owner: postgres
--

COMMENT ON COLUMN sobi_file.archived IS 'Indicates if the file has been moved into the archive location';


--
-- Name: sobi_fragment_process; Type: TABLE; Schema: master; Owner: postgres; Tablespace: 
--

CREATE TABLE sobi_fragment_process (
    id integer NOT NULL,
    fragment_id text NOT NULL
);


ALTER TABLE master.sobi_fragment_process OWNER TO postgres;

--
-- Name: sobi_fragment_process_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE sobi_fragment_process_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.sobi_fragment_process_id_seq OWNER TO postgres;

--
-- Name: sobi_fragment_process_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE sobi_fragment_process_id_seq OWNED BY sobi_fragment_process.id;


SET search_path = public, pg_catalog;

--
-- Name: environment; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE environment (
    id integer NOT NULL,
    schema character varying NOT NULL,
    base_directory character varying NOT NULL,
    staging_directory character varying NOT NULL,
    working_directory character varying NOT NULL,
    archive_directory character varying NOT NULL,
    created_date_time timestamp without time zone NOT NULL,
    modified_date_time timestamp without time zone NOT NULL,
    active boolean NOT NULL
);


ALTER TABLE public.environment OWNER TO postgres;

--
-- Name: environment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE environment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.environment_id_seq OWNER TO postgres;

--
-- Name: environment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE environment_id_seq OWNED BY environment.id;


--
-- Name: member; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE member (
    id integer NOT NULL,
    person_id integer NOT NULL,
    chamber chamber NOT NULL,
    incumbent boolean DEFAULT false,
    full_name character varying
);


ALTER TABLE public.member OWNER TO postgres;

--
-- Name: COLUMN member.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN member.id IS 'Unique member id';


--
-- Name: COLUMN member.person_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN member.person_id IS 'Reference to the person id';


--
-- Name: COLUMN member.chamber; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN member.chamber IS 'Indicates if member is in senate or assembly';


--
-- Name: COLUMN member.incumbent; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN member.incumbent IS 'If true, member is currently in office';


--
-- Name: COLUMN member.full_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN member.full_name IS 'Full name of member listed for convenience';


--
-- Name: member_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE member_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.member_id_seq OWNER TO postgres;

--
-- Name: member_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE member_id_seq OWNED BY member.id;


--
-- Name: member_person_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE member_person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.member_person_id_seq OWNER TO postgres;

--
-- Name: member_person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE member_person_id_seq OWNED BY member.person_id;


--
-- Name: person; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE person (
    id integer NOT NULL,
    full_name character varying,
    first_name character varying,
    middle_name character varying,
    last_name character varying,
    email character varying,
    prefix character varying,
    suffix character varying,
    verified boolean DEFAULT true
);


ALTER TABLE public.person OWNER TO postgres;

--
-- Name: COLUMN person.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN person.id IS 'Unique person id';


--
-- Name: COLUMN person.full_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN person.full_name IS 'Full name of person';


--
-- Name: COLUMN person.first_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN person.first_name IS 'First name of person';


--
-- Name: COLUMN person.middle_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN person.middle_name IS 'Middle name (or initial) of person';


--
-- Name: COLUMN person.last_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN person.last_name IS 'Last name of person';


--
-- Name: COLUMN person.email; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN person.email IS 'The email of the person';


--
-- Name: COLUMN person.prefix; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN person.prefix IS 'Prefix (Mr, Mrs, Senator, etc)';


--
-- Name: COLUMN person.suffix; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN person.suffix IS 'Suffix (Jr, Sr, etc)';


--
-- Name: person_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.person_id_seq OWNER TO postgres;

--
-- Name: person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE person_id_seq OWNED BY person.id;


--
-- Name: session_member; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE session_member (
    id integer NOT NULL,
    member_id integer NOT NULL,
    lbdc_short_name character varying NOT NULL,
    session_year smallint NOT NULL,
    district_code smallint,
    alternate boolean DEFAULT false
);


ALTER TABLE public.session_member OWNER TO postgres;

--
-- Name: session_member_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE session_member_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.session_member_id_seq OWNER TO postgres;

--
-- Name: session_member_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE session_member_id_seq OWNED BY session_member.id;


SET search_path = master, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_info_committee ALTER COLUMN id SET DEFAULT nextval('agenda_info_committee_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_info_committee_item ALTER COLUMN id SET DEFAULT nextval('agenda_info_committee_item_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_vote_committee_attend ALTER COLUMN id SET DEFAULT nextval('agenda_vote_committee_attend_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_vote_committee_vote ALTER COLUMN id SET DEFAULT nextval('agenda_vote_committee_vote_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_amendment_vote_info ALTER COLUMN id SET DEFAULT nextval('bill_amendment_vote_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY calendar_active_list ALTER COLUMN id SET DEFAULT nextval('calendar_active_list_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY calendar_supplemental ALTER COLUMN id SET DEFAULT nextval('calendar_supplemental_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY calendar_supplemental_entry ALTER COLUMN id SET DEFAULT nextval('calendar_supplemental_entry_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY committee ALTER COLUMN id SET DEFAULT nextval('committee_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY committee_member ALTER COLUMN id SET DEFAULT nextval('committee_member_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY committee_version ALTER COLUMN id SET DEFAULT nextval('committee_version_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY sobi_change_log ALTER COLUMN id SET DEFAULT nextval('sobi_change_log_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY sobi_fragment_process ALTER COLUMN id SET DEFAULT nextval('sobi_fragment_process_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY environment ALTER COLUMN id SET DEFAULT nextval('environment_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY member ALTER COLUMN id SET DEFAULT nextval('member_id_seq'::regclass);


--
-- Name: person_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY member ALTER COLUMN person_id SET DEFAULT nextval('member_person_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY person ALTER COLUMN id SET DEFAULT nextval('person_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY session_member ALTER COLUMN id SET DEFAULT nextval('session_member_id_seq'::regclass);


SET search_path = master, pg_catalog;

--
-- Name: agenda_info_addendum_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY agenda_info_addendum
    ADD CONSTRAINT agenda_info_addendum_pkey PRIMARY KEY (agenda_no, year, addendum_id);


--
-- Name: agenda_info_committee_agenda_no_year_addendum_id_committee__key; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY agenda_info_committee
    ADD CONSTRAINT agenda_info_committee_agenda_no_year_addendum_id_committee__key UNIQUE (agenda_no, year, addendum_id, committee_name, committee_chamber);


--
-- Name: agenda_info_committee_item_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY agenda_info_committee_item
    ADD CONSTRAINT agenda_info_committee_item_pkey PRIMARY KEY (id);


--
-- Name: agenda_info_committee_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY agenda_info_committee
    ADD CONSTRAINT agenda_info_committee_pkey PRIMARY KEY (id);


--
-- Name: agenda_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_pkey PRIMARY KEY (agenda_no, year);


--
-- Name: agenda_vote_addendum_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY agenda_vote_addendum
    ADD CONSTRAINT agenda_vote_addendum_pkey PRIMARY KEY (agenda_no, year, addendum_id);


--
-- Name: agenda_vote_committee_agenda_no_year_addendum_id_committee__key; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY agenda_vote_committee
    ADD CONSTRAINT agenda_vote_committee_agenda_no_year_addendum_id_committee__key UNIQUE (agenda_no, year, addendum_id, committee_name, committee_chamber);


--
-- Name: agenda_vote_committee_attend_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY agenda_vote_committee_attend
    ADD CONSTRAINT agenda_vote_committee_attend_pkey PRIMARY KEY (id);


--
-- Name: agenda_vote_committee_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY agenda_vote_committee
    ADD CONSTRAINT agenda_vote_committee_pkey PRIMARY KEY (id);


--
-- Name: agenda_vote_committee_vote_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY agenda_vote_committee_vote
    ADD CONSTRAINT agenda_vote_committee_vote_pkey PRIMARY KEY (id);


--
-- Name: bill_amendment_cosponsor_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bill_amendment_cosponsor
    ADD CONSTRAINT bill_amendment_cosponsor_pkey PRIMARY KEY (bill_print_no, bill_session_year, bill_amend_version, member_id);


--
-- Name: bill_amendment_multi_sponsor_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bill_amendment_multi_sponsor
    ADD CONSTRAINT bill_amendment_multi_sponsor_pkey PRIMARY KEY (bill_print_no, bill_session_year, bill_amend_version, member_id);


--
-- Name: bill_amendment_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bill_amendment
    ADD CONSTRAINT bill_amendment_pkey PRIMARY KEY (bill_print_no, bill_session_year, version);


--
-- Name: bill_amendment_vote_info_bill_print_no_bill_session_year_bi_key; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bill_amendment_vote_info
    ADD CONSTRAINT bill_amendment_vote_info_bill_print_no_bill_session_year_bi_key UNIQUE (bill_print_no, bill_session_year, bill_amend_version, vote_date, vote_type, sequence_no);


--
-- Name: bill_amendment_vote_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bill_amendment_vote_info
    ADD CONSTRAINT bill_amendment_vote_pkey PRIMARY KEY (id);


--
-- Name: bill_amendment_vote_roll_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bill_amendment_vote_roll
    ADD CONSTRAINT bill_amendment_vote_roll_pkey PRIMARY KEY (vote_id, member_id, session_year, vote_code);


--
-- Name: bill_committee_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bill_committee
    ADD CONSTRAINT bill_committee_pkey PRIMARY KEY (bill_print_no, bill_session_year, committee_name, committee_chamber, action_date);


--
-- Name: bill_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bill
    ADD CONSTRAINT bill_pkey PRIMARY KEY (print_no, session_year);


--
-- Name: bill_sponsor_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bill_sponsor
    ADD CONSTRAINT bill_sponsor_pkey PRIMARY KEY (bill_print_no, bill_session_year);


--
-- Name: bill_sponsor_special_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bill_sponsor_additional
    ADD CONSTRAINT bill_sponsor_special_pkey PRIMARY KEY (bill_print_no, bill_session_year, member_id);


--
-- Name: bill_veto_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bill_veto
    ADD CONSTRAINT bill_veto_pkey PRIMARY KEY (veto_number, year);


--
-- Name: calendar_active_list_entry_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calendar_active_list_entry
    ADD CONSTRAINT calendar_active_list_entry_pkey PRIMARY KEY (calendar_active_list_id, bill_calendar_no);


--
-- Name: calendar_active_list_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calendar_active_list
    ADD CONSTRAINT calendar_active_list_pkey PRIMARY KEY (id);


--
-- Name: calendar_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calendar
    ADD CONSTRAINT calendar_pkey PRIMARY KEY (calendar_no, year);


--
-- Name: calendar_supplemental_calendar_no_calendar_year_sup_version_key; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calendar_supplemental
    ADD CONSTRAINT calendar_supplemental_calendar_no_calendar_year_sup_version_key UNIQUE (calendar_no, calendar_year, sup_version);


--
-- Name: calendar_supplemental_entry_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calendar_supplemental_entry
    ADD CONSTRAINT calendar_supplemental_entry_pkey PRIMARY KEY (id);


--
-- Name: calendar_supplemental_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calendar_supplemental
    ADD CONSTRAINT calendar_supplemental_pkey PRIMARY KEY (id);


--
-- Name: committee_member_committee_name_version_created_sequence_no_key; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY committee_member
    ADD CONSTRAINT committee_member_committee_name_version_created_sequence_no_key UNIQUE (committee_name, version_created, sequence_no);


--
-- Name: committee_member_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY committee_member
    ADD CONSTRAINT committee_member_pkey PRIMARY KEY (id);


--
-- Name: committee_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY committee
    ADD CONSTRAINT committee_pkey PRIMARY KEY (name, chamber);


--
-- Name: committee_version_committee_name_chamber_session_year_creat_key; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY committee_version
    ADD CONSTRAINT committee_version_committee_name_chamber_session_year_creat_key UNIQUE (committee_name, chamber, session_year, created);


--
-- Name: committee_version_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY committee_version
    ADD CONSTRAINT committee_version_pkey PRIMARY KEY (id);


--
-- Name: sobi_fragment_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sobi_fragment
    ADD CONSTRAINT sobi_fragment_pkey PRIMARY KEY (fragment_id);


--
-- Name: sobi_fragment_process_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sobi_fragment_process
    ADD CONSTRAINT sobi_fragment_process_pkey PRIMARY KEY (id);


--
-- Name: sobi_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sobi_file
    ADD CONSTRAINT sobi_pkey PRIMARY KEY (file_name);


SET search_path = public, pg_catalog;

--
-- Name: environment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY environment
    ADD CONSTRAINT environment_pkey PRIMARY KEY (id);


--
-- Name: environment_schema_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY environment
    ADD CONSTRAINT environment_schema_key UNIQUE (schema);


--
-- Name: member_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY member
    ADD CONSTRAINT member_pkey PRIMARY KEY (id);


--
-- Name: person_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY person
    ADD CONSTRAINT person_pkey PRIMARY KEY (id);


--
-- Name: session_member_member_id_lbdc_short_name_session_year_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY session_member
    ADD CONSTRAINT session_member_member_id_lbdc_short_name_session_year_key UNIQUE (member_id, lbdc_short_name, session_year);


--
-- Name: session_member_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY session_member
    ADD CONSTRAINT session_member_pkey PRIMARY KEY (id);


SET search_path = master, pg_catalog;

--
-- Name: sobi_change_log_keygin; Type: INDEX; Schema: master; Owner: postgres; Tablespace: 
--

CREATE INDEX sobi_change_log_keygin ON sobi_change_log USING gin (key);


--
-- Name: log_bill_changes; Type: TRIGGER; Schema: master; Owner: postgres
--

CREATE TRIGGER log_bill_changes BEFORE INSERT OR DELETE OR UPDATE ON bill FOR EACH ROW EXECUTE PROCEDURE data_updated();

ALTER TABLE bill DISABLE TRIGGER log_bill_changes;


--
-- Name: agenda_info_addendum_agenda_no_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_info_addendum
    ADD CONSTRAINT agenda_info_addendum_agenda_no_fkey FOREIGN KEY (agenda_no, year) REFERENCES agenda(agenda_no, year) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_info_addendum_last_fragment_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_info_addendum
    ADD CONSTRAINT agenda_info_addendum_last_fragment_id_fkey FOREIGN KEY (last_fragment_id) REFERENCES sobi_fragment(fragment_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_info_committee_agenda_no_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_info_committee
    ADD CONSTRAINT agenda_info_committee_agenda_no_fkey FOREIGN KEY (agenda_no, year, addendum_id) REFERENCES agenda_info_addendum(agenda_no, year, addendum_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_info_committee_committee_name_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_info_committee
    ADD CONSTRAINT agenda_info_committee_committee_name_fkey FOREIGN KEY (committee_name, committee_chamber) REFERENCES committee(name, chamber) ON UPDATE CASCADE;


--
-- Name: agenda_info_committee_item_info_committee_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_info_committee_item
    ADD CONSTRAINT agenda_info_committee_item_info_committee_id_fkey FOREIGN KEY (info_committee_id) REFERENCES agenda_info_committee(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_info_committee_item_last_fragment_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_info_committee_item
    ADD CONSTRAINT agenda_info_committee_item_last_fragment_id_fkey FOREIGN KEY (last_fragment_id) REFERENCES sobi_fragment(fragment_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_info_committee_last_fragment_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_info_committee
    ADD CONSTRAINT agenda_info_committee_last_fragment_id_fkey FOREIGN KEY (last_fragment_id) REFERENCES sobi_fragment(fragment_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_last_fragment_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_last_fragment_id_fkey FOREIGN KEY (last_fragment_id) REFERENCES sobi_fragment(fragment_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_vote_addendum_agenda_no_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_vote_addendum
    ADD CONSTRAINT agenda_vote_addendum_agenda_no_fkey FOREIGN KEY (agenda_no, year) REFERENCES agenda(agenda_no, year) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_vote_addendum_last_fragment_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_vote_addendum
    ADD CONSTRAINT agenda_vote_addendum_last_fragment_id_fkey FOREIGN KEY (last_fragment_id) REFERENCES sobi_fragment(fragment_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_vote_committee_agenda_no_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_vote_committee
    ADD CONSTRAINT agenda_vote_committee_agenda_no_fkey FOREIGN KEY (agenda_no, year, addendum_id) REFERENCES agenda_vote_addendum(agenda_no, year, addendum_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_vote_committee_attend_last_fragment_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_vote_committee_attend
    ADD CONSTRAINT agenda_vote_committee_attend_last_fragment_id_fkey FOREIGN KEY (last_fragment_id) REFERENCES sobi_fragment(fragment_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_vote_committee_attend_member_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_vote_committee_attend
    ADD CONSTRAINT agenda_vote_committee_attend_member_id_fkey FOREIGN KEY (member_id, session_year, lbdc_short_name) REFERENCES public.session_member(member_id, session_year, lbdc_short_name) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_vote_committee_attend_vote_committee_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_vote_committee_attend
    ADD CONSTRAINT agenda_vote_committee_attend_vote_committee_id_fkey FOREIGN KEY (vote_committee_id) REFERENCES agenda_vote_committee(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_vote_committee_committee_name_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_vote_committee
    ADD CONSTRAINT agenda_vote_committee_committee_name_fkey FOREIGN KEY (committee_name, committee_chamber) REFERENCES committee(name, chamber) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_vote_committee_last_fragment_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_vote_committee
    ADD CONSTRAINT agenda_vote_committee_last_fragment_id_fkey FOREIGN KEY (last_fragment_id) REFERENCES sobi_fragment(fragment_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_vote_committee_vote_last_fragment_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_vote_committee_vote
    ADD CONSTRAINT agenda_vote_committee_vote_last_fragment_id_fkey FOREIGN KEY (last_fragment_id) REFERENCES sobi_fragment(fragment_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_vote_committee_vote_refer_committee_name_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_vote_committee_vote
    ADD CONSTRAINT agenda_vote_committee_vote_refer_committee_name_fkey FOREIGN KEY (refer_committee_name, refer_committee_chamber) REFERENCES committee(name, chamber) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_vote_committee_vote_vote_committee_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_vote_committee_vote
    ADD CONSTRAINT agenda_vote_committee_vote_vote_committee_id_fkey FOREIGN KEY (vote_committee_id) REFERENCES agenda_vote_committee(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: agenda_vote_committee_vote_vote_info_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY agenda_vote_committee_vote
    ADD CONSTRAINT agenda_vote_committee_vote_vote_info_id_fkey FOREIGN KEY (vote_info_id) REFERENCES bill_amendment_vote_info(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_amendment_action_bill_print_no_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_amendment_action
    ADD CONSTRAINT bill_amendment_action_bill_print_no_fkey FOREIGN KEY (bill_print_no, bill_session_year, bill_amend_version) REFERENCES bill_amendment(bill_print_no, bill_session_year, version) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_amendment_action_last_fragment_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_amendment_action
    ADD CONSTRAINT bill_amendment_action_last_fragment_id_fkey FOREIGN KEY (last_fragment_id) REFERENCES sobi_fragment(fragment_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_amendment_bill_print_no_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_amendment
    ADD CONSTRAINT bill_amendment_bill_print_no_fkey FOREIGN KEY (bill_print_no, bill_session_year) REFERENCES bill(print_no, session_year) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_amendment_cosponsor_bill_print_no_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_amendment_cosponsor
    ADD CONSTRAINT bill_amendment_cosponsor_bill_print_no_fkey FOREIGN KEY (bill_print_no, bill_session_year, bill_amend_version) REFERENCES bill_amendment(bill_print_no, bill_session_year, version) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_amendment_cosponsor_member_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_amendment_cosponsor
    ADD CONSTRAINT bill_amendment_cosponsor_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_amendment_last_fragment_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_amendment
    ADD CONSTRAINT bill_amendment_last_fragment_id_fkey FOREIGN KEY (last_fragment_id) REFERENCES sobi_fragment(fragment_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_amendment_multi_sponsor_bill_print_no_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_amendment_multi_sponsor
    ADD CONSTRAINT bill_amendment_multi_sponsor_bill_print_no_fkey FOREIGN KEY (bill_print_no, bill_session_year, bill_amend_version) REFERENCES bill_amendment(bill_print_no, bill_session_year, version) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_amendment_multi_sponsor_member_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_amendment_multi_sponsor
    ADD CONSTRAINT bill_amendment_multi_sponsor_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_amendment_same_as_bill_print_no_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_amendment_same_as
    ADD CONSTRAINT bill_amendment_same_as_bill_print_no_fkey FOREIGN KEY (bill_print_no, bill_session_year, bill_amend_version) REFERENCES bill_amendment(bill_print_no, bill_session_year, version) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_amendment_vote_bill_print_no_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_amendment_vote_info
    ADD CONSTRAINT bill_amendment_vote_bill_print_no_fkey FOREIGN KEY (bill_print_no, bill_session_year, bill_amend_version) REFERENCES bill_amendment(bill_print_no, bill_session_year, version) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_amendment_vote_roll_member_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_amendment_vote_roll
    ADD CONSTRAINT bill_amendment_vote_roll_member_id_fkey FOREIGN KEY (member_id, member_short_name, session_year) REFERENCES public.session_member(member_id, lbdc_short_name, session_year) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_amendment_vote_roll_vote_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_amendment_vote_roll
    ADD CONSTRAINT bill_amendment_vote_roll_vote_id_fkey FOREIGN KEY (vote_id) REFERENCES bill_amendment_vote_info(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_committee_bill_print_no_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_committee
    ADD CONSTRAINT bill_committee_bill_print_no_fkey FOREIGN KEY (bill_print_no, bill_session_year) REFERENCES bill(print_no, session_year) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_committee_committee_name_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_committee
    ADD CONSTRAINT bill_committee_committee_name_fkey FOREIGN KEY (committee_name, committee_chamber) REFERENCES committee(name, chamber) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_last_fragment_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill
    ADD CONSTRAINT bill_last_fragment_id_fkey FOREIGN KEY (last_fragment_id) REFERENCES sobi_fragment(fragment_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_previous_version_bill_print_no_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_previous_version
    ADD CONSTRAINT bill_previous_version_bill_print_no_fkey FOREIGN KEY (bill_print_no, bill_session_year) REFERENCES bill(print_no, session_year) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_sponsor_bill_print_no_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_sponsor
    ADD CONSTRAINT bill_sponsor_bill_print_no_fkey FOREIGN KEY (bill_print_no, bill_session_year) REFERENCES bill(print_no, session_year) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_sponsor_member_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_sponsor
    ADD CONSTRAINT bill_sponsor_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bill_veto_bill_print_no_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY bill_veto
    ADD CONSTRAINT bill_veto_bill_print_no_fkey FOREIGN KEY (bill_print_no, session_year) REFERENCES bill(print_no, session_year) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: calendar_active_list_calendar_number_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY calendar_active_list
    ADD CONSTRAINT calendar_active_list_calendar_number_fkey FOREIGN KEY (calendar_no, calendar_year) REFERENCES calendar(calendar_no, year);


--
-- Name: calendar_active_list_entry_calendar_active_list_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY calendar_active_list_entry
    ADD CONSTRAINT calendar_active_list_entry_calendar_active_list_id_fkey FOREIGN KEY (calendar_active_list_id) REFERENCES calendar_active_list(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: calendar_active_list_last_fragment_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY calendar_active_list
    ADD CONSTRAINT calendar_active_list_last_fragment_id_fkey FOREIGN KEY (last_fragment_id) REFERENCES sobi_fragment(fragment_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: calendar_last_fragment_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY calendar
    ADD CONSTRAINT calendar_last_fragment_id_fkey FOREIGN KEY (last_fragment_id) REFERENCES sobi_fragment(fragment_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: calendar_supplemental_calendar_no_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY calendar_supplemental
    ADD CONSTRAINT calendar_supplemental_calendar_no_fkey FOREIGN KEY (calendar_no, calendar_year) REFERENCES calendar(calendar_no, year);


--
-- Name: calendar_supplemental_entry_calendar_sup_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY calendar_supplemental_entry
    ADD CONSTRAINT calendar_supplemental_entry_calendar_sup_id_fkey FOREIGN KEY (calendar_sup_id) REFERENCES calendar_supplemental(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: calendar_supplemental_last_fragment_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY calendar_supplemental
    ADD CONSTRAINT calendar_supplemental_last_fragment_id_fkey FOREIGN KEY (last_fragment_id) REFERENCES sobi_fragment(fragment_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: committee_member_committee_name_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY committee_member
    ADD CONSTRAINT committee_member_committee_name_fkey FOREIGN KEY (committee_name, chamber) REFERENCES committee(name, chamber);


--
-- Name: committee_member_committee_name_fkey1; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY committee_member
    ADD CONSTRAINT committee_member_committee_name_fkey1 FOREIGN KEY (committee_name, chamber, session_year, version_created) REFERENCES committee_version(committee_name, chamber, session_year, created);


--
-- Name: committee_member_member_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY committee_member
    ADD CONSTRAINT committee_member_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: committee_version_committee_name_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY committee_version
    ADD CONSTRAINT committee_version_committee_name_fkey FOREIGN KEY (committee_name, chamber) REFERENCES committee(name, chamber);


--
-- Name: sobi_change_log_sobi_fragment_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY sobi_change_log
    ADD CONSTRAINT sobi_change_log_sobi_fragment_id_fkey FOREIGN KEY (sobi_fragment_id) REFERENCES sobi_fragment(fragment_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sobi_fragment_sobi_file_name_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY sobi_fragment
    ADD CONSTRAINT sobi_fragment_sobi_file_name_fkey FOREIGN KEY (sobi_file_name) REFERENCES sobi_file(file_name) ON UPDATE CASCADE ON DELETE CASCADE;


SET search_path = public, pg_catalog;

--
-- Name: member_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY member
    ADD CONSTRAINT member_person_id_fkey FOREIGN KEY (person_id) REFERENCES person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_member_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY session_member
    ADD CONSTRAINT session_member_member_id_fkey FOREIGN KEY (member_id) REFERENCES member(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

