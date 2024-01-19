CLASS zcl_cronos_visitors_count_cds5 DEFINITION
PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .

  PROTECTED SECTION.


  PRIVATE SECTION.

    CONSTANTS:
      co_fieldname_id     TYPE name_feld VALUE 'ID' ##NO_TEXT,
      co_fieldname_vcount TYPE name_feld VALUE 'VISITORSCOUNT' ##NO_TEXT.

    TYPES:
      BEGIN OF ty_wpref_virt_prop,
        VisitorsCount TYPE int8,
      END OF ty_wpref_virt_prop.

ENDCLASS.


CLASS zcl_cronos_visitors_count_cds5 IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA:
      virtual_properties  TYPE STANDARD TABLE OF ty_wpref_virt_prop.

    LOOP AT it_original_data ASSIGNING FIELD-SYMBOL(<music>).
      ASSIGN COMPONENT co_fieldname_id OF STRUCTURE <music> TO FIELD-SYMBOL(<music_id>).

      IF sy-subrc = 0.
        APPEND VALUE #( VisitorsCount = 1379 * <music_id> ) TO virtual_properties.
        UNASSIGN <music_id>.
      ELSE.
        RETURN.
      ENDIF.

    ENDLOOP.

    IF sy-subrc = 0.
      ct_calculated_data[] = virtual_properties[].
    ENDIF.

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<calc_element>).
      CASE <calc_element>.
        WHEN co_fieldname_vcount.
          APPEND co_fieldname_id TO et_requested_orig_elements.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
