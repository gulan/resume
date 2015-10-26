-- sqlite3 resume.db <resume.sql
-- echo "select * from rst;" | sqlite3 resume.db | rst2html >resume.rst.html

drop table if exists topic;
drop table if exists discipline;
drop table if exists company;
drop table if exists stint;
drop table if exists claim;
drop table if exists summary;
drop table if exists address;
drop table if exists project;
drop table if exists education;
drop table if exists property;
drop table if exists refurl;

drop view if exists rst;
drop view if exists rst_address;
drop view if exists rst_summary;
drop view if exists rst_experience;
drop view if exists rst_technology;
drop view if exists rst_education;

create table property (
    property_name text not null,
    property_value text not null);

insert into property values ('version', '1.0');

create table address (
    address_id integer primary key autoincrement,
    my_name text not null,
    street text,
    city_state text,
    email text,
    home text,
    cell text,
    url text);

create table refurl (
    url_id integer primary key autoincrement,
    tag text not null,
    url text not null);

insert into refurl (tag,url) values ('Github', 'https://github.com/gulan');
insert into refurl (tag,url) values ('LinkedIn', 'https://www.linkedin.com/pub/glen-wilder/0/4b7/653');
insert into refurl (tag,url) values ('Sourceforge', 'https://sourceforge.net/u/gwilder');

create table summary (
    summary_id integer primary key autoincrement,
    summary_desc text not null);

create table project (
    project_id integer primary key autoincrement,
    url text,
    project_desc text not null);

create table company (
    company_id integer primary key,
    company_name text not null,
    city text not null,
    aka text);

create table stint (
    stint_id integer primary key,
    start_month text not null,
    start_year text not null,
    end_month text not null,
    end_year text not null,
    title text not null,
    company_id references company,
    emptype text not null);

create table claim (
    claim_id integer primary key autoincrement,
    stint_id references stint,
    claim_text text not null);

create table topic (
   topic_id integer primary key,
   topic_desc text not null);

create table discipline (
    discipline_id integer primary key autoincrement,
    discipline_desc text not null,
    topic_id references topic,
    effective integer not null); -- weeks needed to become effectively useful with the skill again.

create table education (
   school_name text not null,
   school_city text not null,
   subject text not null,
   year text not null,
   gpa text not null);

--        - - -  Address  - - -  
create view rst_address as
  select '| ' || my_name from address
  union all
  select '| ' || city_state from address
  union all
  select '| ' || email from address
  union all
  select '| ' || tag || ': ' || url from refurl;

--        - - -  Summary  - - -  
create view rst_summary as
  select '* ' || summary_desc
  from summary;

--       - - -  Experience  - - - 
create view rst_experience as
    select line from (
        select 'a' as code, stint_id,
               start_year || ' - ' || end_year || ' ' || s.title || case s.emptype when 'Employee' then '' else ' (Contract)' end || ' - '  || co.company_name as line
        from stint s, company co
        where stint_id < 10
        and s.company_id = co.company_id 
    union all 
        select 'b' as code, sb.stint_id, '------------------------------------------------------------------------------' as line
        from stint sb
        where sb.stint_id < 10
    union all 
        select 'c' as code, cl.stint_id, '* ' || cl.claim_text as line
        from claim cl
    union all 
        select 'd' as code, sd.stint_id, ' ' as line
        from stint sd
        where sd.stint_id < 10
        order by s.stint_id, code
    );

--        - - -  Technology  - - -  
-- 2 kinds of line: topic-name, skill-list. These lines are paired by
-- topic. There are 1+ pairs.

create view rst_technology as 
    select line from (
        select topic_id, 'a' as code, ' ' as line
        from topic
    union all 
        select topic_id, 'b' as code, '**' || topic_desc || '**' as line 
        from topic
    union all
        select t.topic_id, 'c' as code, '    ' || group_concat(d.discipline_desc, ', ') as line
        from discipline d, topic t 
        where d.effective < 2  and  d.topic_id = t.topic_id
        group by t.topic_id
        order by t.topic_id, code);

--        - - -  Education  - - -  
create view rst_education as
    select line from (
        select year ||' - '|| school_name ||' - '|| school_city ||' (GPA: '|| gpa || ')'as line from education
        union all
        select '--------------------------------------------------------------------------------'
        union all
        select '* Courses: ' || subject as line from education);

-- Resume formatted as restructured text
create view rst as
    select '=====================' 
    union all select 'Resume of Glen Wilder' 
    union all select '=====================' 
    union all select * from rst_address
    union all select ' ' 
    union all select '----------------------------------------' 
    union all select ' ' 
    union all select * from rst_summary
    union all select ' '
    union all select 'EXPERIENCE' 
    union all select '==========' 
    union all select '2014 - *present* Private Projects'
    union all select '---------------------------------'
    union all select '* Requirements Engineering Management System'
    union all select '* Learn Haskell'
    union all select ' '
    union all select * from rst_experience
    union all select ' ' 
    union all select 'PROJECTS' 
    union all select '========' 
    union all select '* ' || project_desc || ' (https://' || url || ')' from project
    union all select ' ' 
    union all select 'TECHNOLOGY' 
    union all select '==========' 
    union all select * from rst_technology
    union all select ' ' 
    union all select 'EDUCATION' 
    union all select '========='
    union all select * from rst_education;
    -- union all select ':Version: '||property_value from property where property_name = 'version'

--        - - -  Projects  - - -  
insert into project (url,project_desc) values ('gist.github.com/gulan','Recent code samples may be found on Github');
insert into project (url,project_desc) values ('sourceforge.net/projects/pyprolog','Developed the SourceForge project PyProlog, an embedding of SWI-Prolog in Python');

insert into address (my_name,city_state,email) values ('Glen Wilder','Santa Clara, CA','glen.wilder@gmail.com');

insert into summary (summary_desc) values ('Continuous Python programming since 1996');
insert into summary (summary_desc) values ('Linux, C and SQL programming experience');
insert into summary (summary_desc) values ('Over 30 years experience with Software Design, Automated Testing, Object-Oriented Programming, Project Management');
insert into summary (summary_desc) values ('Industry background includes File System Protocols, Cloud Storage, Financial Applications, Telephony, Biotechnology');

insert into topic values (1,'Skills');
insert into topic values (2,'OS');
insert into topic values (3,'Hardware');
insert into topic values (4,'Software');
insert into topic values (5,'Languages');
insert into topic values (6,'Protocols');
-- insert into topic values (7,'Methods');

insert into discipline (discipline_desc,topic_id,effective) values ('Automated Testing',1,0);
insert into discipline (discipline_desc,topic_id,effective) values ('Concurrent Programming',1,2);
insert into discipline (discipline_desc,topic_id,effective) values ('System Analysis and Design',1,0);
insert into discipline (discipline_desc,topic_id,effective) values ('Data Modeling',1,1);
insert into discipline (discipline_desc,topic_id,effective) values ('Object Design Patterns',1,1);
insert into discipline (discipline_desc,topic_id,effective) values ('Object-Oriented Programming',1,0);
insert into discipline (discipline_desc,topic_id,effective) values ('Open Source Development',1,1);
insert into discipline (discipline_desc,topic_id,effective) values ('PC Hardware Configuration',1,0);
insert into discipline (discipline_desc,topic_id,effective) values ('Project Planning',1,0);
insert into discipline (discipline_desc,topic_id,effective) values ('Property-Based Testing',1,1);
insert into discipline (discipline_desc,topic_id,effective) values ('Refactoring',1,0);
insert into discipline (discipline_desc,topic_id,effective) values ('Test Planning',1,0);
insert into discipline (discipline_desc,topic_id,effective) values ('UNIX System Administration',1,1);
insert into discipline (discipline_desc,topic_id,effective) values ('Requirements Engineering',1,0);
insert into discipline (discipline_desc,topic_id,effective) values ('Structured Programming',1,0);
insert into discipline (discipline_desc,topic_id,effective) values ('UML',1,2);
insert into discipline (discipline_desc,topic_id,effective) values ('Formal Methods',1,4);

insert into discipline (discipline_desc,topic_id,effective) values ('Ubuntu',2,0);
insert into discipline (discipline_desc,topic_id,effective) values ('Debian',2,0);
insert into discipline (discipline_desc,topic_id,effective) values ('Red Hat',2,1);
insert into discipline (discipline_desc,topic_id,effective) values ('MS Windows',2,2);
insert into discipline (discipline_desc,topic_id,effective) values ('Virtualbox',2,1);
insert into discipline (discipline_desc,topic_id,effective) values ('FreeBSD',2,1);
insert into discipline (discipline_desc,topic_id,effective) values ('Arch Linux',2,2);
insert into discipline (discipline_desc,topic_id,effective) values ('Solaris',2,2);
insert into discipline (discipline_desc,topic_id,effective) values ('VMWare',2,2);
insert into discipline (discipline_desc,topic_id,effective) values ('VM/CMS',2,2);
insert into discipline (discipline_desc,topic_id,effective) values ('MVS',2,2);
insert into discipline (discipline_desc,topic_id,effective) values ('CICS',2,2);
insert into discipline (discipline_desc,topic_id,effective) values ('QEMU',2,2);
insert into discipline (discipline_desc,topic_id,effective) values ('Bochs',2,2);
insert into discipline (discipline_desc,topic_id,effective) values ('OS X',2,2);
insert into discipline (discipline_desc,topic_id,effective) values ('NextStep',2,2);

insert into discipline (discipline_desc,topic_id,effective) values ('x86_64',3,0);
insert into discipline (discipline_desc,topic_id,effective) values ('MacBook',3,1);
insert into discipline (discipline_desc,topic_id,effective) values ('Raspberry Pi',3,0);
insert into discipline (discipline_desc,topic_id,effective) values ('NetApp',3,1);
insert into discipline (discipline_desc,topic_id,effective) values ('IBM Mainframe',3,1);
insert into discipline (discipline_desc,topic_id,effective) values ('T1',3,3);
insert into discipline (discipline_desc,topic_id,effective) values ('Aculab Telephony',3,4);

insert into discipline (discipline_desc,topic_id,effective) values ('Wireshark',4,0);
insert into discipline (discipline_desc,topic_id,effective) values ('tcpdump',4,0);
insert into discipline (discipline_desc,topic_id,effective) values ('Bugzilla',4,0);
insert into discipline (discipline_desc,topic_id,effective) values ('Sqlite3',4,0);
insert into discipline (discipline_desc,topic_id,effective) values ('Redmine',4,0);
insert into discipline (discipline_desc,topic_id,effective) values ('git',4,0);
insert into discipline (discipline_desc,topic_id,effective) values ('GCC',4,0);
insert into discipline (discipline_desc,topic_id,effective) values ('SSH',4,0);
insert into discipline (discipline_desc,topic_id,effective) values ('Emacs',4,0);
insert into discipline (discipline_desc,topic_id,effective) values ('make',4,1);
insert into discipline (discipline_desc,topic_id,effective) values ('GDB',4,1);
insert into discipline (discipline_desc,topic_id,effective) values ('Perforce',4,1);
insert into discipline (discipline_desc,topic_id,effective) values ('Subversion',4,1);
insert into discipline (discipline_desc,topic_id,effective) values ('CVS',4,1);
insert into discipline (discipline_desc,topic_id,effective) values ('SWIG',4,1);
insert into discipline (discipline_desc,topic_id,effective) values ('uboot',4,2);
insert into discipline (discipline_desc,topic_id,effective) values ('Oracle 8.0',4,2);
insert into discipline (discipline_desc,topic_id,effective) values ('PostgreSQL',4,2);
insert into discipline (discipline_desc,topic_id,effective) values ('Visual Studio 6.0',4,2);

-- insert into discipline (discipline_desc,topic_id,effective) values ('6502 Assembly',5);
insert into discipline (discipline_desc,topic_id,effective) values ('Python',5,0);
insert into discipline (discipline_desc,topic_id,effective) values ('SQL',5,0);
insert into discipline (discipline_desc,topic_id,effective) values ('C',5,0);
insert into discipline (discipline_desc,topic_id,effective) values ('Bash',5,0);
insert into discipline (discipline_desc,topic_id,effective) values ('Perl',5,1);
insert into discipline (discipline_desc,topic_id,effective) values ('Prolog',5,1);
insert into discipline (discipline_desc,topic_id,effective) values ('Scheme',5,1);
insert into discipline (discipline_desc,topic_id,effective) values ('TCL/TK',5,1);
insert into discipline (discipline_desc,topic_id,effective) values ('Expect',5,1);
insert into discipline (discipline_desc,topic_id,effective) values ('Javascript',5,2);
insert into discipline (discipline_desc,topic_id,effective) values ('Erlang',5,2);
insert into discipline (discipline_desc,topic_id,effective) values ('Java',5,2);
insert into discipline (discipline_desc,topic_id,effective) values ('Alloy',5,3);
insert into discipline (discipline_desc,topic_id,effective) values ('C++',5,4);
-- insert into discipline (discipline_desc,topic_id,effective) values ('COBOL',5,1);
insert into discipline (discipline_desc,topic_id,effective) values ('Elixir',5,3);
insert into discipline (discipline_desc,topic_id,effective) values ('Forth',5,3);
insert into discipline (discipline_desc,topic_id,effective) values ('Haskell',5,3);
insert into discipline (discipline_desc,topic_id,effective) values ('IBM 370 Assembly',5,4);
insert into discipline (discipline_desc,topic_id,effective) values ('Lisp',5,3);
insert into discipline (discipline_desc,topic_id,effective) values ('Z',5,3);
insert into discipline (discipline_desc,topic_id,effective) values ('SML/NJ',5,3);

insert into discipline (discipline_desc,topic_id,effective) values ('NFS',6,0);
insert into discipline (discipline_desc,topic_id,effective) values ('TCP/IP',6,0);
insert into discipline (discipline_desc,topic_id,effective) values ('Telnet',6,0);
insert into discipline (discipline_desc,topic_id,effective) values ('XMLRPC',6,0);
insert into discipline (discipline_desc,topic_id,effective) values ('Serial/TTY/RS232',6,1);
insert into discipline (discipline_desc,topic_id,effective) values ('CIFS/SMB',6,2);
insert into discipline (discipline_desc,topic_id,effective) values ('Ethernet',6,1);
insert into discipline (discipline_desc,topic_id,effective) values ('FTP',6,1);
insert into discipline (discipline_desc,topic_id,effective) values ('HTTP',6,1);
insert into discipline (discipline_desc,topic_id,effective) values ('ISCSI',6,3);

insert into education values ('ECPI', 'Topeka, KS', 'Data Processing, COBOL, IBM 360 Assembly', '1978', '3.6');

insert into company values (1,'Exablox','Sunnyvale,CA',NULL);
insert into company values (2,'NetApp','Sunnyvale,CA','Network Appliance');
insert into company values (3,'Cirtas Systems','San Jose, CA',NULL);
insert into company values (4,'Dana Software','San Jose, CA', 'Message Hero');
insert into company values (5,'Molecular Applications Group','Palo Alto, CA',NULL);
insert into company values (6,'SGI','Mountain View, CA', 'Silicon Graphics');
insert into company values (7,'Filoli Information Systems','Palo Alto, CA',NULL);
insert into company values (8,'McKesson', 'San Francisco, CA',NULL);
insert into company values (9,'Kaiser Permanente','Oakland, CA',NULL);
insert into company values (10,'California State Automobile Assoc.','San Francisco, CA','CSAAA');
insert into company values (11,'First Nationwide Bank','Folsom, CA',NULL);
insert into company values (12,'Vision Service Plan','Sacramento, CA',NULL);
insert into company values (13,'County of Alameda','Oakland, CA',NULL);
insert into company values (14,'TDS','Santa Clara, CA','Technicon Data Systems');
insert into company values (15,'Informatics','Palo Alto, CA',NULL);
insert into company values (16,'Fleming Foods','Topeka, KS',NULL);

insert into stint values (1,'01','2012','05','2014','QA Automation Engineer/Manager', 1, 'Employee');
insert into stint values (2,'10','2011','01','2012','QA Automation Engineer', 2,'Contract');
insert into stint values (3,'06','2010','05','2011','Lead QA Automation Engineer', 3, 'Employee');
insert into stint values (4,'10','2004','06','2010','QA Automation Engineer', 2, 'Employee');
insert into stint values (5,'05','2002','11','2003','Lead Software Engineer/Manager', 4, 'Employee');
insert into stint values (6,'08','1998','05','1999','Software Developer', 5, 'Contract');
insert into stint values (7,'03','1998','08','1998','Test Engineer', 6, 'Contract');
insert into stint values (8,'04','1996','08','1997','Software Developer', 7, 'Employee');
insert into stint values (9,'08','1994','10','1995','Programmer/Analyst', 8, 'Contract');
insert into stint values (10,'01','1993','09','1993','Programmer/Analyst', 9, 'Contract');
insert into stint values (11,'10','1992','12','1992','Programmer', 10, 'Contract');
insert into stint values (12,'04','1992','07','1992','Programmer/Analyst', 11, 'Contract');
insert into stint values (13,'01','1992','03','1992','Programmer/Analyst', 12, 'Contract');
insert into stint values (14,'07','1990','01','1991','Programmer/Analyst', 13, 'Contract');
-- insert into stint values (15,'1983','1989','Programmer',14,'Employee');
-- insert into stint values (16,'1982','1983','Programmer/Analyst',15,'Employee');
-- insert into stint values (17,'1979','1982','Programmer/Analyst',16,'Employee');

insert into claim (stint_id,claim_text) values (1,'First QA hire. Built the QA Department from scratch');
insert into claim (stint_id,claim_text) values (1,'Specified and oversaw QA workflow, test case development and scheduling');
insert into claim (stint_id,claim_text) values (1,'Setup QA lab. Planned lab expansions. Ordered hardware and built server machines');
insert into claim (stint_id,claim_text) values (1,'Forecast upcoming hardware and staffing needs');
insert into claim (stint_id,claim_text) values (1,'Represented QA at executive staff meetings');
insert into claim (stint_id,claim_text) values (1,'Wrote NTFS test scripts, and SSD performance and endurance tests');
insert into claim (stint_id,claim_text) values (1,'Designed file system snapshot test cases and automation');
insert into claim (stint_id,claim_text) values (1,'Automated server OS install via serial port with Raspberry Pi');
insert into claim (stint_id,claim_text) values (1,'Taught Python to QA staff');
insert into claim (stint_id,claim_text) values (1,'Technologies: Python, Debian, CIFS, SMB, FUSE, VirtualBox, Clustered Servers, Git, Redmine, Google Docs, Javascript');

insert into claim (stint_id,claim_text) values (2,'Automated NFS file locking tests in Perl');
insert into claim (stint_id,claim_text) values (2,'Technologies: NFSv4, NFSv4.1. Perl, Perforce, tcpdump');

insert into claim (stint_id,claim_text) values (3,'Implemented white box tests to verify the correctness and effectiveness of the disk cache subsystem');
insert into claim (stint_id,claim_text) values (3,'Designed concurrent scripts to test recovery from ISCSI service interruptions');
insert into claim (stint_id,claim_text) values (3,'Implemented a XMLRPC client, providing command-line access to remote server');
insert into claim (stint_id,claim_text) values (3,'Reorganized Python packages, wrote packaging, installation and unit test scripts');
insert into claim (stint_id,claim_text) values (3,'Created a tool to query and update the Testlink QA test management system');
insert into claim (stint_id,claim_text) values (3,'Technologies: ISCSI, Amazon S3, Cloud Storage, Linux, VMware, XMLPRC, Python, Erlang, Bugzilla, Testlink');

insert into claim (stint_id,claim_text) values (4,'Wrote a distributed testing framework in Python');
insert into claim (stint_id,claim_text) values (4,'Designed tests for the NFS protocols and the WAFL file system');
insert into claim (stint_id,claim_text) values (4,'Coded test scripts in Python and Perl');
insert into claim (stint_id,claim_text) values (4,'Wrote an NFS 3 synthetic client for server protocol testing');
insert into claim (stint_id,claim_text) values (4,'Supported and enhanced PyNFS, an Open Source implementation of NFS v4 in Python');
insert into claim (stint_id,claim_text) values (4,'Did mentoring and training of the NFS QA staff. Subjects included Python, RFCs, automated testing techniques and UNIX');
insert into claim (stint_id,claim_text) values (4,'Technologies: NFSv4, NFSv3, Python, Perl, Socket Programming, Perforce, git, tcpdump, Solaris, Linux, BSD');

insert into claim (stint_id,claim_text) values (5,'Project lead for a team of 5 engineers that designed, implemented and deployed the VoiceForm system, a telephony and voice recognition system');
insert into claim (stint_id,claim_text) values (5,'Embedded Python in the C++ telephony server');
insert into claim (stint_id,claim_text) values (5,'Met with customers to refine requirements');
insert into claim (stint_id,claim_text) values (5,'Wrote product release procedures. Automated build and install steps');
insert into claim (stint_id,claim_text) values (5,'Promoted to Manager of Software Development');
insert into claim (stint_id,claim_text) values (5,'Technologies: Python, C++, Voice Recognition, T1, PostgreSQL, CVS');

insert into claim (stint_id,claim_text) values (6,'Worked directly with company scientists to prototype bioinformatic software tools');
insert into claim (stint_id,claim_text) values (6,'Implemented a framework for clustering phylogenetic trees');
insert into claim (stint_id,claim_text) values (6,'Wrote a protein threading calibration suite');
insert into claim (stint_id,claim_text) values (6,'Prototyped statistical clustering algorithms for gene expression');
insert into claim (stint_id,claim_text) values (6,'Interfaced Python with C libraries');
insert into claim (stint_id,claim_text) values (6,'Translated scripts from Perl to Python, and from Python to Perl');
insert into claim (stint_id,claim_text) values (6,'Technologies: Python, C, Perl, Prolog, Java, CVS');

insert into claim (stint_id,claim_text) values (7,'Led the testing effort for the Field Service Engineers Tools software through two release cycles');
insert into claim (stint_id,claim_text) values (7,'Wrote project test plans and designed test cases');
insert into claim (stint_id,claim_text) values (7,'Implemented a CGI/HTML local web server to report test results');
insert into claim (stint_id,claim_text) values (7,'Wrote Python scripts to remotely configure lab systems to test diagnostic software');
insert into claim (stint_id,claim_text) values (7,'Technologies: Python, Expect, Bash, IRIX, HTML, Telnet');

insert into claim (stint_id,claim_text) values (8,'Designed and wrote an object-oriented framework for testing NextStep GUI applications');
insert into claim (stint_id,claim_text) values (8,'Created a screen image record and playback utility');
insert into claim (stint_id,claim_text) values (8,'Technologies: Python, Objective-C, NeXTStep, Sybase, TCL');

insert into claim (stint_id,claim_text) values (9,'Re-engineered eight combinatorial payment matching algorithms');
insert into claim (stint_id,claim_text) values (9,'Ported legacy software to Millennium A/R System');
insert into claim (stint_id,claim_text) values (9,'Documented production system designs, workflows and procedures');

