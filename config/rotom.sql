--
-- PostgreSQL database dump
--

-- Dumped from database version 11.4 (Debian 11.4-1)
-- Dumped by pg_dump version 11.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ffzu; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ffzu (
    id integer NOT NULL,
    mkzi text NOT NULL,
    yshu integer NOT NULL,
    iljmriqi timestamp with time zone DEFAULT now(),
    CONSTRAINT ffzu_mkzi_check CHECK ((mkzi <> ''::text))
);


--
-- Name: ffzu_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ffzu_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ffzu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ffzu_id_seq OWNED BY public.ffzu.id;


--
-- Name: yshu; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.yshu (
    id integer NOT NULL,
    mkzi text NOT NULL,
    iljmriqi timestamp with time zone DEFAULT now(),
    CONSTRAINT yshu_mkzi_check CHECK ((mkzi <> ''::text))
);


--
-- Name: yshu_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.yshu_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: yshu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.yshu_id_seq OWNED BY public.yshu.id;


--
-- Name: ffzu id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ffzu ALTER COLUMN id SET DEFAULT nextval('public.ffzu_id_seq'::regclass);


--
-- Name: yshu id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.yshu ALTER COLUMN id SET DEFAULT nextval('public.yshu_id_seq'::regclass);


--
-- Name: ffzu ffzu_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ffzu
    ADD CONSTRAINT ffzu_pkey PRIMARY KEY (id);


--
-- Name: yshu yshu_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.yshu
    ADD CONSTRAINT yshu_pkey PRIMARY KEY (id);


--
-- Name: ffzu ffzu_yshu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ffzu
    ADD CONSTRAINT ffzu_yshu_fkey FOREIGN KEY (yshu) REFERENCES public.yshu(id);


--
-- PostgreSQL database dump complete
--

