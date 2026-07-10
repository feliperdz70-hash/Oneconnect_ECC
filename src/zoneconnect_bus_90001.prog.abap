*****           Implementation of object type ZBUS_90001           *****
INCLUDE <OBJECT>.
BEGIN_DATA OBJECT. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
" begin of private,
"   to declare private attributes remove comments and
"   insert private attributes here ...
" end of private,
  BEGIN OF KEY,
      CONDITIONRECORDNO LIKE KONH-KNUMH,
  END OF KEY.
END_DATA OBJECT. " Do not change.. DATA is generated

BEGIN_METHOD DISPLAY CHANGING CONTAINER.
END_METHOD.

BEGIN_METHOD EXISTENCECHECK CHANGING CONTAINER.
END_METHOD.
