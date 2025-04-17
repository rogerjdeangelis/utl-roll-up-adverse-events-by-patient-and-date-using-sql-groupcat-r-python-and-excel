%let pgm=utl-roll-up-adverse-events-by-patient-and-date-using-sql-groupcat-r-python-and-excel;

%stop_submission;

Roll up adverse events by patient and date using sql group_concat with r python and excel

 SAS does not support the group_cancat sql function

  CONTENTS

     1 r sql
     2 python sql
     3 excel sql

github
https://tinyurl.com/5jj9t8wu
https://github.com/rogerjdeangelis/utl-roll-up-adverse-events-by-patient-and-date-using-sql-groupcat-r-python-and-excel

related to:
https://tinyurl.com/mv2f7azp
https://communities.sas.com/t5/SAS-Programming/How-do-I-make-subjects-with-the-same-date-in-multiple-rows-go-in/m-p/829271#M327622

/**************************************************************************************************************************/
/*         INPUT                  |         PROCESS                              |        OUTPUT                          */
/*         =====                  |         =======                              |        ======                          */
/*                                |                                              |                                        */
/*                                |                                              |                                        */
/* ID AE_TYPE  AE_DATE            | DATA SORTEED FOR DUCUMENTATION               | R                                      */
/*                                |                                              |                                        */
/*  1    A    2022-08-05          | ID AE_TYPE   AE_DATE  OUTPUT                 | ID    AE_DATE   aes                    */
/*  1    B                        |                                              |                                        */
/*  1    C    2022-08-05          |  1    B                 B                    |  1                B                    */
/*  1    D    2022-08-05          |  1    E     2022-06-23  E                    |  1 2022-06-23     E                    */
/*  1    E    2022-06-23          |                                              |  1 2022-08-05 A,C,D                    */
/*  2    A                        |  1    A     2022-08-05                       |  2              A,E                    */
/*  2    B    2019-05-07          |  1    C     2022-08-05                       |  2 2019-05-07   B,D                    */
/*  2    C    2020-04-15          |  1    D     2022-08-05  A,C,D (same id date) |  2 2020-04-15     C                    */
/*  2    D    2019-05-07          |  2    A                                      |  3              B,E                    */
/*  2    E                        |  2    E                 A,E                  |  3 2016-07-21     A                    */
/*  3    A    2016-07-21          |  2    B     2019-05-07                       |  3 2017-11-09     D                    */
/*  3    B                        |  2    D     2019-05-07  B,D                  |  3 2018-09-25     C                    */
/*  3    C    2018-09-25          |                                              |                                        */
/*  3    D    2017-11-09          |  2    C     2020-04-15  C                    |                                        */
/*  3    E                        |  3    B                                      | SAS                                    */
/*                                |  3    E                 B,E                  |                                        */
/* options                        |  3    A     2016-07-21  A                    | ROWS ID     AE_DATE      AES           */
/*   validvarname=upcase;         |                                              |                                        */
/* libname sd1 "d:/sd1";          |  3    D     2017-11-09  D                    |  1    1                  B             */
/* data sd1.have;                 |                                              |  2    1    2022-06-23    E             */
/*  input ID AE_TYPE $            |  3    C     2018-09-25  C                    |  3    1    2022-08-05    A,C,D         */
/*   AE_DATE $10.;                |                                              |  4    2                  A,E           */
/* cards;                         |                                              |  5    2    2019-05-07    B,D           */
/* 1 A 2022-08-05                 |  R SQL (python and excel see below)          |  6    2    2020-04-15    C             */
/* 1 B .                          |                                              |  7    3                  B,E           */
/* 1 C 2022-08-05                 |  %utl_rbeginx;                               |  8    3    2016-07-21    A             */
/* 1 D 2022-08-05                 |  parmcards4;                                 |  9    3    2017-11-09    D             */
/* 1 E 2022-06-23                 |  library(haven)                              | 10    3    2018-09-25    C             */
/* 2 A .                          |  library(sqldf)                              |                                        */
/* 2 B 2019-05-07                 |  source("c:/oto/fn_tosas9x.R")               |                                        */
/* 2 C 2020-04-15                 |  have<-read_sas("d:/sd1/have.sas7bdat")      |                                        */
/* 2 D 2019-05-07                 |  print(have)                                 |                                        */
/* 2 E .                          |  want<-sqldf('                               |                                        */
/* 3 A 2016-07-21                 |     select                                   |                                        */
/* 3 B .                          |        id                                    |                                        */
/* 3 C 2018-09-25                 |       ,ae_date                               |                                        */
/* 3 D 2017-11-09                 |       ,group_concat(ae_type) as aes          |                                        */
/* 3 E .                          |     from                                     |                                        */
/* ;;;;                           |        have                                  |                                        */
/* run;quit;                      |     group                                    |                                        */
/*                                |        by id, ae_date                        |                                        */
/*                                |     ')                                       |                                        */
/*                                |  want                                        |                                        */
/*                                |  fn_tosas9x(                                 |                                        */
/*                                |        inp    = want                         |                                        */
/*                                |       ,outlib ="d:/sd1/"                     |                                        */
/*                                |       ,outdsn ="want"                        |                                        */
/*                                |       )                                      |                                        */
/*                                |  ;;;;                                        |                                        */
/*                                |  %utl_rendx;                                 |                                        */
/**************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

 options
   validvarname=upcase;
 libname sd1 "d:/sd1";
 data sd1.have;
  input ID AE_TYPE $
   AE_DATE $10.;
 cards;
 1 A 2022-08-05
 1 B .
 1 C 2022-08-05
 1 D 2022-08-05
 1 E 2022-06-23
 2 A .
 2 B 2019-05-07
 2 C 2020-04-15
 2 D 2019-05-07
 2 E .
 3 A 2016-07-21
 3 B .
 3 C 2018-09-25
 3 D 2017-11-09
 3 E .
 ;;;;
 run;quit;

/**************************************************************************************************************************/
/* ID AE_TYPE  AE_DATE                                                                                                    */
/*                                                                                                                        */
/*  1    A    2022-08-05                                                                                                  */
/*  1    B                                                                                                                */
/*  1    C    2022-08-05                                                                                                  */
/*  1    D    2022-08-05                                                                                                  */
/*  1    E    2022-06-23                                                                                                  */
/*  2    A                                                                                                                */
/*  2    B    2019-05-07                                                                                                  */
/*  2    C    2020-04-15                                                                                                  */
/*  2    D    2019-05-07                                                                                                  */
/*  2    E                                                                                                                */
/*  3    A    2016-07-21                                                                                                  */
/*  3    B                                                                                                                */
/*  3    C    2018-09-25                                                                                                  */
/*  3    D    2017-11-09                                                                                                  */
/*  3    E                                                                                                                */
/**************************************************************************************************************************/

/*                    _
/ |  _ __   ___  __ _| |
| | | `__| / __|/ _` | |
| | | |    \__ \ (_| | |
|_| |_|    |___/\__, |_|
                   |_|
*/

proc datasets lib=sd1 nolist nodetails;
 delete want;
run;quit;

%utl_rbeginx;
parmcards4;
library(haven)
library(sqldf)
source("c:/oto/fn_tosas9x.R")
have<-read_sas("d:/sd1/have.sas7bdat")
print(have)
want<-sqldf('
   select
      id
     ,ae_date
     ,group_concat(ae_type) as aes
   from
      have
   group
      by id, ae_date
   ')
want
fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="want"
     )
;;;;
%utl_rendx;

proc print data=sd1.want;
run;quit;

/**************************************************************************************************************************/
/* R                     |  SAS                                                                                           */
/* ID    AE_DATE   AES   |  ROWNAMES    ID     AE_DATE      AES                                                           */
/*                       |                                                                                                */
/*  1                B   |      1        1                  B                                                             */
/*  1 2022-06-23     E   |      2        1    2022-06-23    E                                                             */
/*  1 2022-08-05 A,C,D   |      3        1    2022-08-05    A,C,D                                                         */
/*  2              A,E   |      4        2                  A,E                                                           */
/*  2 2019-05-07   B,D   |      5        2    2019-05-07    B,D                                                           */
/*  2 2020-04-15     C   |      6        2    2020-04-15    C                                                             */
/*  3              B,E   |      7        3                  B,E                                                           */
/*  3 2016-07-21     A   |      8        3    2016-07-21    A                                                             */
/*  3 2017-11-09     D   |      9        3    2017-11-09    D                                                             */
/*  3 2018-09-25     C   |     10        3    2018-09-25    C                                                             */
/**************************************************************************************************************************/

/*___                _   _                             _
|___ \   _ __  _   _| |_| |__   ___  _ __    ___  __ _| |
  __) | | `_ \| | | | __| `_ \ / _ \| `_ \  / __|/ _` | |
 / __/  | |_) | |_| | |_| | | | (_) | | | | \__ \ (_| | |
|_____| | .__/ \__, |\__|_| |_|\___/|_| |_| |___/\__, |_|
        |_|    |___/                                |_|
*/


proc datasets lib=sd1 nolist nodetails;
 delete pywant;
run;quit;

%utl_pybeginx;
parmcards4;
exec(open('c:/oto/fn_python.py').read());
have,meta = ps.read_sas7bdat('d:/sd1/have.sas7bdat');
want=pdsql('''
   select                            \
      id                             \
     ,ae_date                        \
     ,group_concat(ae_type) as aes   \
   from                              \
      have                           \
   group                             \
      by id, ae_date                 \
   ''');
print(want);
fn_tosas9x(want,outlib='d:/sd1/',outdsn='pywant',timeest=3);
;;;;
%utl_pyendx;

proc print data=sd1.pywant;
run;quit;

/**************************************************************************************************************************/
/*  PYTHON                          SAS                                                                                   */
/*      ID     AE_DATE    AES       ID     AE_DATE      AES                                                               */
/*                                                                                                                        */
/*  0  1.0                  B        1                  B                                                                 */
/*  1  1.0  2022-06-23      E        1    2022-06-23    E                                                                 */
/*  2  1.0  2022-08-05  A,C,D        1    2022-08-05    A,C,D                                                             */
/*  3  2.0                A,E        2                  A,E                                                               */
/*  4  2.0  2019-05-07    B,D        2    2019-05-07    B,D                                                               */
/*  5  2.0  2020-04-15      C        2    2020-04-15    C                                                                 */
/*  6  3.0                B,E        3                  B,E                                                               */
/*  7  3.0  2016-07-21      A        3    2016-07-21    A                                                                 */
/*  8  3.0  2017-11-09      D        3    2017-11-09    D                                                                 */
/*  9  3.0  2018-09-25      C        3    2018-09-25    C                                                                 */
/**************************************************************************************************************************/

/*____                     _
|___ /    _____  _____ ___| |
  |_ \   / _ \ \/ / __/ _ \ |
 ___) | |  __/>  < (_|  __/ |
|____/   \___/_/\_\___\___|_|

*/

/*----  CREATE INPUT -----*/

%utlfkil(d:/xls/wantxl.xlsx);

%utl_rbeginx;
parmcards4;
library(openxlsx)
library(sqldf)
library(haven)
have<-read_sas("d:/sd1/have.sas7bdat")
wb <- createWorkbook()
addWorksheet(wb, "have")
writeData(wb, sheet = "have", x = have)
saveWorkbook(
    wb
   ,"d:/xls/wantxl.xlsx"
   ,overwrite=TRUE)
;;;;
%utl_rendx;

%utl_rbeginx;
parmcards4;
library(openxlsx)
library(sqldf)
source("c:/oto/fn_tosas9x.R")
 wb<-loadWorkbook("d:/xls/wantxl.xlsx")
 have<-read.xlsx(wb,"have")
 addWorksheet(wb, "want")
 want<-sqldf('
   select
      id
     ,ae_date
     ,group_concat(ae_type) as aes
   from
      have
   group
      by id, ae_date
  ')
 print(want)
 writeData(wb,sheet="want",x=want)
 saveWorkbook(
     wb
    ,"d:/xls/wantxl.xlsx"
    ,overwrite=TRUE)
fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="want"
     )
;;;;
%utl_rendx;

proc print data=sd1.want;
run;quit;

/**************************************************************************************************************************/
/* -----------------------+                                                                                               */
/* | A1| fx       |  ID   |                                                                                               */
/* ------------------------------------+                                                                                  */
/* [_] |    A     |    B     |    C    |                                                                                  */
/* ------------------------------------|                                                                                  */
/*  1  |   ID     | AE_DATE  | AES     |                                                                                  */
/*  -- |----------+---------++---------|                                                                                  */
/*  2  |   1      |          |  B      |                                                                                  */
/*  -- |----------+---------++---------|                                                                                  */
/*  3  |   1      |2022-06-23|  E      |                                                                                  */
/*  -- |----------+---------++---------|                                                                                  */
/*  4  |   1      |2022-08-05|  A,C,D  |                                                                                  */
/*  -- |----------+---------++---------|                                                                                  */
/*  5  |   2      |          |  A,E    |                                                                                  */
/*  -- |----------+---------++---------|                                                                                  */
/*  6  |   2      |2019-05-07|  B,D    |                                                                                  */
/*  -- |----------+---------++---------|                                                                                  */
/*  7  |   2      |2020-04-15|  C      |                                                                                  */
/*  -- |----------+---------++---------|                                                                                  */
/*  8  |   3      |          |  B,E    |                                                                                  */
/*  -- |----------+---------++---------|                                                                                  */
/*  9  |   3      |2016-07-21|  A      |                                                                                  */
/*  -- |----------+---------++---------|                                                                                  */
/* 10  |   3      |2017-11-09|  D      |                                                                                  */
/*  -- |----------+---------++---------|                                                                                  */
/* 11  |   3      |2018-09-25|  C      |                                                                                  */
/*  -- |----------+---------++---------+                                                                                  */
/* [WANT]                                                                                                                 */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
