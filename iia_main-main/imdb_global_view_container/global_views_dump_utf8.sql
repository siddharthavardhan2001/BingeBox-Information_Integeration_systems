--
-- PostgreSQL database dump
--

\restrict tAwSSP9xLCiULnXfvr4C173PTG71apeth3yO1fzyOe6lAbv4LicDnXrOpTY50TF

-- Dumped from database version 18.0 (Debian 18.0-1.pgdg13+3)
-- Dumped by pg_dump version 18.0 (Debian 18.0-1.pgdg13+3)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: global_views; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA global_views;


ALTER SCHEMA global_views OWNER TO postgres;

--
-- Name: imdb_movies; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA imdb_movies;


ALTER SCHEMA imdb_movies OWNER TO postgres;

--
-- Name: imdb_tvseries; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA imdb_tvseries;


ALTER SCHEMA imdb_tvseries OWNER TO postgres;

--
-- Name: postgres_fdw; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;


--
-- Name: EXTENSION postgres_fdw; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';


--
-- Name: imdb_movies_server; Type: SERVER; Schema: -; Owner: postgres
--

CREATE SERVER imdb_movies_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (
    dbname 'postgres',
    host 'imdb_movies_container',
    port '5432'
);


ALTER SERVER imdb_movies_server OWNER TO postgres;

--
-- Name: USER MAPPING postgres SERVER imdb_movies_server; Type: USER MAPPING; Schema: -; Owner: postgres
--

CREATE USER MAPPING FOR postgres SERVER imdb_movies_server OPTIONS (
    "user" 'postgres',
    password 'postgres'
);


--
-- Name: imdb_tvseries_server; Type: SERVER; Schema: -; Owner: postgres
--

CREATE SERVER imdb_tvseries_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (
    dbname 'postgres',
    host 'imdb_tvseries_container',
    port '5432'
);


ALTER SERVER imdb_tvseries_server OWNER TO postgres;

--
-- Name: USER MAPPING postgres SERVER imdb_tvseries_server; Type: USER MAPPING; Schema: -; Owner: postgres
--

CREATE USER MAPPING FOR postgres SERVER imdb_tvseries_server OPTIONS (
    "user" 'postgres',
    password 'postgres'
);


--
-- Name: imdb_movies_actors; Type: FOREIGN TABLE; Schema: public; Owner: postgres
--

CREATE FOREIGN TABLE public.imdb_movies_actors (
    actor_id integer,
    name text
)
SERVER imdb_movies_server
OPTIONS (
    schema_name 'public',
    table_name 'actors'
);


ALTER FOREIGN TABLE public.imdb_movies_actors OWNER TO postgres;

--
-- Name: imdb_movies_movie_cast; Type: FOREIGN TABLE; Schema: public; Owner: postgres
--

CREATE FOREIGN TABLE public.imdb_movies_movie_cast (
    movie_id text,
    actor_id integer,
    role text
)
SERVER imdb_movies_server
OPTIONS (
    schema_name 'public',
    table_name 'movie_cast'
);


ALTER FOREIGN TABLE public.imdb_movies_movie_cast OWNER TO postgres;

--
-- Name: imdb_tvseries_actors; Type: FOREIGN TABLE; Schema: public; Owner: postgres
--

CREATE FOREIGN TABLE public.imdb_tvseries_actors (
    actor_id integer,
    name text
)
SERVER imdb_tvseries_server
OPTIONS (
    schema_name 'public',
    table_name 'actors'
);


ALTER FOREIGN TABLE public.imdb_tvseries_actors OWNER TO postgres;

--
-- Name: imdb_tvseries_show_cast; Type: FOREIGN TABLE; Schema: public; Owner: postgres
--

CREATE FOREIGN TABLE public.imdb_tvseries_show_cast (
    show_id integer,
    actor_id integer
)
SERVER imdb_tvseries_server
OPTIONS (
    schema_name 'public',
    table_name 'show_cast'
);


ALTER FOREIGN TABLE public.imdb_tvseries_show_cast OWNER TO postgres;

--
-- Name: global_cast; Type: VIEW; Schema: global_views; Owner: postgres
--

CREATE VIEW global_views.global_cast AS
 SELECT ('M'::text || mc.movie_id) AS content_global_id,
    'movie'::text AS content_type,
    a.name AS actor_name,
    mc.role,
    'imdb_movies'::text AS source_schema
   FROM (public.imdb_movies_movie_cast mc
     JOIN public.imdb_movies_actors a ON ((mc.actor_id = a.actor_id)))
UNION ALL
 SELECT ('T'::text || sc.show_id) AS content_global_id,
    'tv'::text AS content_type,
    a.name AS actor_name,
    NULL::text AS role,
    'imdb_tvseries'::text AS source_schema
   FROM (public.imdb_tvseries_show_cast sc
     JOIN public.imdb_tvseries_actors a ON ((sc.actor_id = a.actor_id)));


ALTER VIEW global_views.global_cast OWNER TO postgres;

--
-- Name: imdb_movies_directors; Type: FOREIGN TABLE; Schema: public; Owner: postgres
--

CREATE FOREIGN TABLE public.imdb_movies_directors (
    director_id integer,
    name text
)
SERVER imdb_movies_server
OPTIONS (
    schema_name 'public',
    table_name 'directors'
);


ALTER FOREIGN TABLE public.imdb_movies_directors OWNER TO postgres;

--
-- Name: imdb_movies_movies; Type: FOREIGN TABLE; Schema: public; Owner: postgres
--

CREATE FOREIGN TABLE public.imdb_movies_movies (
    id text,
    name text,
    release_date text,
    release_type text,
    director_id integer,
    duration_mins integer,
    url text,
    description text
)
SERVER imdb_movies_server
OPTIONS (
    schema_name 'public',
    table_name 'movies'
);


ALTER FOREIGN TABLE public.imdb_movies_movies OWNER TO postgres;

--
-- Name: imdb_tvseries_tvshows; Type: FOREIGN TABLE; Schema: public; Owner: postgres
--

CREATE FOREIGN TABLE public.imdb_tvseries_tvshows (
    id integer,
    title text,
    about text,
    rating real,
    years text
)
SERVER imdb_tvseries_server
OPTIONS (
    schema_name 'public',
    table_name 'tvshows'
);


ALTER FOREIGN TABLE public.imdb_tvseries_tvshows OWNER TO postgres;

--
-- Name: global_content; Type: VIEW; Schema: global_views; Owner: postgres
--

CREATE VIEW global_views.global_content AS
 SELECT ('M'::text || m.id) AS content_global_id,
    'movie'::text AS content_type,
    m.name AS title,
    NULL::text AS description,
    NULL::real AS rating,
    m.release_date,
    m.duration_mins,
    d.name AS director_name,
    'imdb_movies'::text AS source_schema
   FROM (public.imdb_movies_movies m
     LEFT JOIN public.imdb_movies_directors d ON ((m.director_id = d.director_id)))
UNION ALL
 SELECT ('T'::text || t.id) AS content_global_id,
    'tv'::text AS content_type,
    t.title,
    t.about AS description,
    t.rating,
    t.years AS release_date,
    NULL::integer AS duration_mins,
    NULL::text AS director_name,
    'imdb_tvseries'::text AS source_schema
   FROM public.imdb_tvseries_tvshows t;


ALTER VIEW global_views.global_content OWNER TO postgres;

--
-- Name: imdb_movies_genres; Type: FOREIGN TABLE; Schema: public; Owner: postgres
--

CREATE FOREIGN TABLE public.imdb_movies_genres (
    genre_id integer,
    name text
)
SERVER imdb_movies_server
OPTIONS (
    schema_name 'public',
    table_name 'genres'
);


ALTER FOREIGN TABLE public.imdb_movies_genres OWNER TO postgres;

--
-- Name: imdb_movies_movie_genres; Type: FOREIGN TABLE; Schema: public; Owner: postgres
--

CREATE FOREIGN TABLE public.imdb_movies_movie_genres (
    movie_id text,
    genre_id integer
)
SERVER imdb_movies_server
OPTIONS (
    schema_name 'public',
    table_name 'movie_genres'
);


ALTER FOREIGN TABLE public.imdb_movies_movie_genres OWNER TO postgres;

--
-- Name: imdb_tvseries_genres; Type: FOREIGN TABLE; Schema: public; Owner: postgres
--

CREATE FOREIGN TABLE public.imdb_tvseries_genres (
    genre_id integer,
    name text
)
SERVER imdb_tvseries_server
OPTIONS (
    schema_name 'public',
    table_name 'genres'
);


ALTER FOREIGN TABLE public.imdb_tvseries_genres OWNER TO postgres;

--
-- Name: imdb_tvseries_show_genres; Type: FOREIGN TABLE; Schema: public; Owner: postgres
--

CREATE FOREIGN TABLE public.imdb_tvseries_show_genres (
    show_id integer,
    genre_id integer
)
SERVER imdb_tvseries_server
OPTIONS (
    schema_name 'public',
    table_name 'show_genres'
);


ALTER FOREIGN TABLE public.imdb_tvseries_show_genres OWNER TO postgres;

--
-- Name: global_genres; Type: VIEW; Schema: global_views; Owner: postgres
--

CREATE VIEW global_views.global_genres AS
 SELECT ('M'::text || mg.movie_id) AS content_global_id,
    'movie'::text AS content_type,
    g.name AS genre_name,
    'imdb_movies'::text AS source_schema
   FROM (public.imdb_movies_movie_genres mg
     JOIN public.imdb_movies_genres g ON ((mg.genre_id = g.genre_id)))
UNION ALL
 SELECT ('T'::text || sg.show_id) AS content_global_id,
    'tv'::text AS content_type,
    g.name AS genre_name,
    'imdb_tvseries'::text AS source_schema
   FROM (public.imdb_tvseries_show_genres sg
     JOIN public.imdb_tvseries_genres g ON ((sg.genre_id = g.genre_id)));


ALTER VIEW global_views.global_genres OWNER TO postgres;

--
-- Name: actors; Type: FOREIGN TABLE; Schema: imdb_movies; Owner: postgres
--

CREATE FOREIGN TABLE imdb_movies.actors (
    actor_id integer,
    name text
)
SERVER imdb_movies_server
OPTIONS (
    schema_name 'public',
    table_name 'actors'
);


ALTER FOREIGN TABLE imdb_movies.actors OWNER TO postgres;

--
-- Name: directors; Type: FOREIGN TABLE; Schema: imdb_movies; Owner: postgres
--

CREATE FOREIGN TABLE imdb_movies.directors (
    director_id integer,
    name text
)
SERVER imdb_movies_server
OPTIONS (
    schema_name 'public',
    table_name 'directors'
);


ALTER FOREIGN TABLE imdb_movies.directors OWNER TO postgres;

--
-- Name: genres; Type: FOREIGN TABLE; Schema: imdb_movies; Owner: postgres
--

CREATE FOREIGN TABLE imdb_movies.genres (
    genre_id integer,
    name text
)
SERVER imdb_movies_server
OPTIONS (
    schema_name 'public',
    table_name 'genres'
);


ALTER FOREIGN TABLE imdb_movies.genres OWNER TO postgres;

--
-- Name: movie_cast; Type: FOREIGN TABLE; Schema: imdb_movies; Owner: postgres
--

CREATE FOREIGN TABLE imdb_movies.movie_cast (
    movie_id text,
    actor_id integer,
    role text
)
SERVER imdb_movies_server
OPTIONS (
    schema_name 'public',
    table_name 'movie_cast'
);


ALTER FOREIGN TABLE imdb_movies.movie_cast OWNER TO postgres;

--
-- Name: movie_genres; Type: FOREIGN TABLE; Schema: imdb_movies; Owner: postgres
--

CREATE FOREIGN TABLE imdb_movies.movie_genres (
    movie_id text,
    genre_id integer
)
SERVER imdb_movies_server
OPTIONS (
    schema_name 'public',
    table_name 'movie_genres'
);


ALTER FOREIGN TABLE imdb_movies.movie_genres OWNER TO postgres;

--
-- Name: movies; Type: FOREIGN TABLE; Schema: imdb_movies; Owner: postgres
--

CREATE FOREIGN TABLE imdb_movies.movies (
    id text,
    name text,
    release_date text,
    release_type text,
    director_id integer,
    duration_mins integer,
    url text,
    description text
)
SERVER imdb_movies_server
OPTIONS (
    schema_name 'public',
    table_name 'movies'
);


ALTER FOREIGN TABLE imdb_movies.movies OWNER TO postgres;

--
-- Name: actors; Type: FOREIGN TABLE; Schema: imdb_tvseries; Owner: postgres
--

CREATE FOREIGN TABLE imdb_tvseries.actors (
    actor_id integer,
    name text
)
SERVER imdb_tvseries_server
OPTIONS (
    schema_name 'public',
    table_name 'actors'
);


ALTER FOREIGN TABLE imdb_tvseries.actors OWNER TO postgres;

--
-- Name: genres; Type: FOREIGN TABLE; Schema: imdb_tvseries; Owner: postgres
--

CREATE FOREIGN TABLE imdb_tvseries.genres (
    genre_id integer,
    name text
)
SERVER imdb_tvseries_server
OPTIONS (
    schema_name 'public',
    table_name 'genres'
);


ALTER FOREIGN TABLE imdb_tvseries.genres OWNER TO postgres;

--
-- Name: show_cast; Type: FOREIGN TABLE; Schema: imdb_tvseries; Owner: postgres
--

CREATE FOREIGN TABLE imdb_tvseries.show_cast (
    show_id integer,
    actor_id integer
)
SERVER imdb_tvseries_server
OPTIONS (
    schema_name 'public',
    table_name 'show_cast'
);


ALTER FOREIGN TABLE imdb_tvseries.show_cast OWNER TO postgres;

--
-- Name: show_genres; Type: FOREIGN TABLE; Schema: imdb_tvseries; Owner: postgres
--

CREATE FOREIGN TABLE imdb_tvseries.show_genres (
    show_id integer,
    genre_id integer
)
SERVER imdb_tvseries_server
OPTIONS (
    schema_name 'public',
    table_name 'show_genres'
);


ALTER FOREIGN TABLE imdb_tvseries.show_genres OWNER TO postgres;

--
-- Name: tvshows; Type: FOREIGN TABLE; Schema: imdb_tvseries; Owner: postgres
--

CREATE FOREIGN TABLE imdb_tvseries.tvshows (
    id integer,
    title text,
    about text,
    rating real,
    years text
)
SERVER imdb_tvseries_server
OPTIONS (
    schema_name 'public',
    table_name 'tvshows'
);


ALTER FOREIGN TABLE imdb_tvseries.tvshows OWNER TO postgres;

--
-- PostgreSQL database dump complete
--

\unrestrict tAwSSP9xLCiULnXfvr4C173PTG71apeth3yO1fzyOe6lAbv4LicDnXrOpTY50TF

