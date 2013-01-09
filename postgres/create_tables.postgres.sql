CREATE TABLE rapidsms_contact
(
  id serial NOT NULL,
  name character varying(100) NOT NULL,
  language character varying(6) NOT NULL,
  user_id integer,
  reporting_location_id integer,
  birthdate timestamp with time zone,
  gender character varying(1),
  village_id integer,
  village_name character varying(100),
  role_id integer,
  supply_point_id integer,
  --needs_reminders boolean NOT NULL,
  --is_active boolean NOT NULL,
  --is_approved boolean NOT NULL,
  --active boolean NOT NULL,
  CONSTRAINT rapidsms_contact_pkey PRIMARY KEY (id )--,
  --CONSTRAINT reporting_location_id_refs_id_8c3a8f57 FOREIGN KEY (reporting_location_id)
   --   REFERENCES locations_location (id) MATCH SIMPLE
  --    ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
  --CONSTRAINT user_id_refs_id_c38d4eb8 FOREIGN KEY (user_id)
    --  REFERENCES auth_user (id) MATCH SIMPLE
      --ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
 -- CONSTRAINT village_id_refs_id_8c3a8f57 FOREIGN KEY (village_id)
   --   REFERENCES locations_location (id) MATCH SIMPLE
     -- ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
  -- CONSTRAINT rapidsms_contact_user_id_key UNIQUE (user_id )
);
CREATE TABLE rapidsms_backend
(
  id serial NOT NULL,
  name character varying(20) NOT NULL,
  CONSTRAINT rapidsms_backend_pkey PRIMARY KEY (id ),
  CONSTRAINT rapidsms_backend_name_key UNIQUE (name )
);
CREATE TABLE rapidsms_connection
(
  id serial NOT NULL,
  backend_id integer NOT NULL,
  identity character varying(100) NOT NULL,
  contact_id integer,
  CONSTRAINT rapidsms_connection_pkey PRIMARY KEY (id ),
  CONSTRAINT rapidsms_connection_backend_id_fkey FOREIGN KEY (backend_id)
      REFERENCES rapidsms_backend (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
 -- CONSTRAINT rapidsms_connection_contact_id_fkey FOREIGN KEY (contact_id)
  --    REFERENCES rapidsms_contact (id) MATCH SIMPLE
   --   ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT rapidsms_connection_backend_id_identity_key UNIQUE (backend_id , identity )
);
CREATE TABLE rapidsms_xforms_xformsubmission
(
  id serial NOT NULL,
  xform_id integer NOT NULL,
  type character varying(8) ,--NOT NULL,
  connection_id integer,
  "raw" text NOT NULL,
  has_errors boolean NOT NULL,
  created timestamp with time zone , --NOT NULL,
  confirmation_id integer, -- NOT NULL,
  message_id integer,
  approved boolean, -- NOT NULL,
  CONSTRAINT rapidsms_xforms_xformsubmission_pkey PRIMARY KEY (id )
--  CONSTRAINT connection_id_refs_id_513b0e17421f5b43 FOREIGN KEY (connection_id)
  --    REFERENCES rapidsms_connection (id) MATCH SIMPLE
    --  ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED

);
CREATE SEQUENCE seq_id_gen START WITH 10;
--
-- db_category
--
CREATE TABLE db_category (
  id        varchar(9)  NOT NULL,
  name      varchar(30) NOT NULL,
  parent_id varchar(9)  default NULL,
  PRIMARY KEY  (id),
  CONSTRAINT db_category_parent_fk FOREIGN KEY (parent_id) REFERENCES db_category (id)
);
CREATE INDEX db_cat_parent_fki ON db_category (parent_id);
--
-- db_product
--
CREATE TABLE db_product (
  ean_code     varchar(13)  NOT NULL,
  name         varchar(30)  NOT NULL,
  category_id  varchar(9)   NOT NULL,
  price        decimal(8,2) NOT NULL,
  manufacturer varchar(30)  NOT NULL,
  notes        varchar(256)     NULL,
  description  text             NULL,
--  image        bytea            NULL, TODO support bytea type
  PRIMARY KEY  (ean_code),
  CONSTRAINT db_product_category_fk FOREIGN KEY (category_id) REFERENCES db_category (id)
);
CREATE INDEX db_product_category_fki ON db_product (category_id);
--
-- db_role
--
CREATE TABLE db_role (
  name varchar(16) NOT NULL,
  PRIMARY KEY  (name)
);
--
-- db_user
--
CREATE TABLE db_user (
  id       integer     NOT NULL DEFAULT nextval('seq_id_gen'),
  name     varchar(30) NOT NULL,
  email    varchar(50) NOT NULL,
  password varchar(16) NOT NULL,
  role_id  varchar(16) NOT NULL,
  active   smallint    NOT NULL default 1,
  PRIMARY KEY  (id),
  CONSTRAINT db_user_role_fk FOREIGN KEY (role_id) REFERENCES db_role (name),
  constraint active_flag check (active in (0,1))
);
CREATE INDEX db_user_role_fki on db_user (role_id);
--
-- db_customer
--
CREATE TABLE db_customer (
  id         integer      NOT NULL default 0,
  category   char(1)      NOT NULL,
  salutation varchar(10),
  first_name varchar(30)  NOT NULL,
  last_name  varchar(30)  NOT NULL,
  birth_date date,
  PRIMARY KEY  (id),
  CONSTRAINT db_customer_user_fk FOREIGN KEY (id) REFERENCES db_user (id)
);
--
-- db_order
--
CREATE TABLE db_order (
  id          integer   NOT NULL DEFAULT nextval('seq_id_gen'),
  customer_id integer   NOT NULL,
  total_price     decimal(8,2) NOT NULL,
  created_at  timestamp NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT db_order_customer_fk FOREIGN KEY (customer_id) REFERENCES db_customer (id)
);
CREATE INDEX db_order_customer_fki on db_order (customer_id);
--
-- db_order_item
--
CREATE TABLE db_order_item (
  id              integer      NOT NULL DEFAULT nextval('seq_id_gen'),
  order_id        integer      NOT NULL,
  number_of_items integer      NOT NULL default 1,
  product_ean_code      varchar(13)  NOT NULL,
  total_price     decimal(8,2) NOT NULL,
  PRIMARY KEY  (id),
  CONSTRAINT db_order_item_order_fk FOREIGN KEY (order_id) REFERENCES db_order (id),
  CONSTRAINT db_order_item_product_fk FOREIGN KEY (product_ean_code) REFERENCES db_product (ean_code)
);
CREATE INDEX db_order_item_order_fki ON db_order_item (order_id);
CREATE INDEX db_order_item_product_fki ON db_order_item (product_ean_code);
COMMIT;
