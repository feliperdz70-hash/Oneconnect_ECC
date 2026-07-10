FUNCTION ZONFM_RSCHECK_WHITELISTTAB.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(VALUE)
*"     REFERENCE(WHITELIST) TYPE  ANY TABLE
*"  EXCEPTIONS
*"      NOT_IN_WHITELIST
*"--------------------------------------------------------------------

read table whitelist from value transporting no fields.
if sy-subrc <> 0.
  raise not_in_whitelist.
endif.

ENDFUNCTION.
