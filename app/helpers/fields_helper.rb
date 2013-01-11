module FieldsHelper
     
  def field_edit_helper(field,can_edit = false)
     render 'shared/edit_info', {type: 'field', field: field, value: @field[field], row_id: @field.id, can_edit: can_edit}
  end
  
  def get_field_name (field)
    if field == 1
      "Time"
    elsif field == 2
      "Number"
    elsif field == 3
      "Text"
    elsif field == 4
      "Longitude"
    elsif field == 5
      "Latitude"
    end
  end
  
  def get_field_type (field)
    if field == "Time"
      1
    elsif field == "Number"
      2
    elsif field == "Text"
      3
    elsif field == "Longitude"
      4
    elsif field == "Latitude"
      5
    end
  end

end