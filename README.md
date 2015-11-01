My resume in SQL.

An HTML rendering of the resume may be produced by,

    sqlite3 resume.db <resume.sql
    echo "select * from rst;" | sqlite3 resume.db | rst2html >resume.rst.html

These commands require that sqlite3 and reStructuredText be installed
on a UNIX system.

    echo "select * from rst;" | sqlite3 resume.db | pandoc -f rst -o resume.md

Why did I do this? For fun, mainly, but it actually works quite
well. Using database views lets me keep a clean separation between the
logical content and any rendered presentations that I might like to
create. Right now, I only have an rst view, but it should be easy to
add Markdown and LaTex views too.

