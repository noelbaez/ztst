class zcl_salv_handler definition
  public
  final
  create public .

  public section.
    methods: on_user_command for event added_function of cl_salv_events importing e_salv_function,
      on_double_click for event double_click of cl_salv_events_table importing row column.

  protected section.
  private section.
ENDCLASS.



CLASS ZCL_SALV_HANDLER IMPLEMENTATION.


  method on_double_click.
    case column.
      when 'XXX'.
    endcase.
  endmethod.


  method on_user_command.
    case e_salv_function.
      when 'XXX'.
    endcase.
  endmethod.                    "on_user_command
ENDCLASS.
