@echo off

rem
rem Name:    Deploy.cmd
rem Purpose: To deploy a set of .sql files to a named SQL Server and Database.
rem Author:  RSutherland
rem Date:    2007.02.21
rem
rem Revised 2007.03.08 for Release 1.04
rem    1. Added the "/f" option to the "del" command; this allows the deletes to delete
rem       read-only files
rem    2. Moved processing of indexes up so they would process prior to foreign keys
rem
rem
rem Copyright (C) 2007 Richard Sutherland <rvsutherland@gmail.com>
rem
rem This program is free software; you can redistribute it and/or
rem modify it under the terms of the GNU General Public License
rem as published by the Free Software Foundation; either version 2
rem of the License, or (at your option) any later version.
rem
rem This program is distributed in the hope that it will be useful,
rem but WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem GNU General Public License for more details.
rem
rem You should have received a copy of the GNU General Public License
rem along with this program; if not, write to the Free Software
rem Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
rem
rem The GNU General Public License is located at:
rem    http://www.gnu.org/licenses/gpl.html#SEC1
rem

echo %0
echo.

date /t
time /t
echo.

rem 3 parameters are required
rem
if %3xyandz == xyandz goto explain

rem parameter 1 must be a valid path
rem
if not exist %1 (
   echo ERROR: "%1" is not a valid path
   goto end
)

cd %1

rem try to connect to test the server and database
rem
osql -E -S %2 -d %3 -b -Q "print 'Connected to Server %2, Database %3'"

rem if the connection failed, the server and/or database were bogus and reason was displayed
rem
if errorlevel 1 (
   echo ERROR: Connection failed. See above reason.
   goto end
)

rem if optional 4th parameter is "/d", files will be deleted after processing
rem
echo.
if x%4yz == x/dyz (
   setlocal
   set delete=true
   echo Files will be deleted after processing.
)

if x%4yz neq x/dyz (
   echo Files will be retained after processing.
)

echo.
echo ***************  SCHEMAS  ***************
echo.

if not exist %1\Security\Schemas goto users

cd %1\Security\Schemas

for %%f in (*.schema.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

:users

echo ***************  USERS  ***************
echo.

if not exist %1\Security\Users goto roles

cd %1\Security\Users

for %%f in (*.user.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

:roles

echo ***************  ROLES  ***************
echo.

if not exist %1\Security\Roles\"Database Roles" goto approles

cd %1\Security\Roles\"Database Roles"

for %%f in (*.role.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

:approles

echo ***************  APPLICATION ROLES  ***************
echo.

if not exist %1\Security\Roles\"Application Roles" goto catalogs

cd %1\Security\Roles\"Application Roles"

for %%f in (*.approle.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

:catalogs

echo ***************  FULL TEXT CATALOGS  ***************
echo.

if not exist %1\Storage\"Full Text Catalogs" goto uddts

cd %1\Storage\"Full Text Catalogs"

for %%f in (*.fulltext.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

:uddts

echo ***************  USER DEFINED TYPES  ***************
echo.

if not exist %1\Types\"User-defined Data Types" goto xmlschemas

cd %1\Types\"User-defined Data Types"

for %%f in (*.*.uddt.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

:xmlschemas

echo ***************  XML SCHEMA COLLECTIONS  ***************
echo.

if not exist %1\Types\"XML Schema Collections" goto functions

cd %1\Types\"XML Schema Collections"

for %%f in (*.*.xmlschema.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

:functions

echo ***************  USER DEFINED FUNCTIONS  ***************
echo.

if not exist %1\Functions goto tables

cd %1\Functions

for %%f in (*.*.function.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

:tables

echo ***************  TABLES  ***************
echo.

if not exist %1\Tables goto views

cd %1\Tables

for %%f in (*.*.table.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

rem
rem execute any files which ALTER, DELETE, INSERT & UPDATE tables
for %%f in (*.*.table.*.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

echo ***************  PRIMARY KEYS  ***************
echo.

if not exist %1\Tables\Keys goto constraints

cd %1\Tables\Keys

for %%f in (*.*.*.pkey.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

echo ***************  UNIQUE KEYS  ***************
echo.

for %%f in (*.*.*.ukey.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

:indexes

echo ***************  INDEXES  ***************
echo.

if not exist %1\Tables\Indexes goto fkeys

cd %1\Tables\Indexes

for %%f in (*.*.*.index.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

:fkeys

echo ***************  FOREIGN KEYS  ***************
echo.

if not exist %1\Tables\Keys goto constraints

cd %1\Tables\Keys

for %%f in (*.*.*.fkey.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

:constraints

echo ***************  CONSTRAINTS  ***************
echo.

if not exist %1\Tables\Constraints goto views

cd %1\Tables\Constraints

for %%f in (*.*.*.*const.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

:views

echo ***************  VIEWS  ***************
echo.

if not exist %1\Views goto procs

cd %1\Views

for %%f in (*.*.view.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

echo ***************  INDEXES ON VIEWS  ***************
echo.

if not exist %1\Views\Indexes goto procs

cd %1\Views\Indexes

for %%f in (*.*.*.index.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

:procs

echo ***************  STORED PROCEDURES  ***************
echo.

if not exist %1\"Stored Procedures" goto triggers

cd %1\"Stored Procedures"

for %%f in (*.*.proc.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

:triggers

echo ***************  TRIGGERS  ***************
echo.

if not exist %1\Tables\Triggers goto viewtriggers

cd %1\Tables\Triggers

for %%f in (*.*.*.trigger.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

:viewtriggers

if not exist %1\Views\Triggers goto ddltriggers

cd %1\Views\Triggers

for %%f in (*.*.*.trigger.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

:ddltriggers

echo ***************  DATABASE TRIGGERS  ***************
echo.

if not exist %1\"Database Triggers" goto synonyms

cd %1\"Database Triggers"

for %%f in (*.ddltrigger.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

:synonyms

echo ***************  SYNONYMS  ***************
echo.

if not exist %1\Synonyms goto end

cd %1\Synonyms

for %%f in (*.synonym.sql) do (
   echo File:  %%f
   osql -E -S %2 -d %3 -n -i "%%f"
   echo.
   if defined delete del /f "%%f"
)

goto end

:explain
echo.
echo Usage:
echo.
echo Deploy "<Root Path>" ^<ServerName^> ^<DatabaseName^> [/d]
echo.
echo Where ^<Root Path^> is the full path to the top of the tree where the files
echo reside. This will typically be the "Schema Objects" folder. It is assumed
echo that beneath this folder the structure follows that produced by ScriptDB.exe.
echo.
echo The ServerName and DatabaseName are the target server and database into which
echo the objects should be deployed.
echo.
echo The optional "/d" as the 4th parameter will cause the files to be deleted
echo after they are processed.
echo.

:end

time /t
echo.

echo Done
echo.


