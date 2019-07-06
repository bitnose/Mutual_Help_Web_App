$(document).ready(function() {
                  var max_fields      = 10;
                  var wrapper         = $(".container1");
                  var add_button      = $(".add_form_field1");
                  
                  var x = 1;
                  $(add_button).click(function(e){
                                      e.preventDefault();
                                      if(x < max_fields){
                                      x++;
                                      $(wrapper).append('<div><input type="text" name="demands[]"/><a href="#" class="delete">Delete</a></div>'); //add input box
                                      }
                                      else
                                      {
                                      alert('You Reached the limits')
                                      }
                                      });
                  
                  $(wrapper).on("click",".delete", function(e){
                                e.preventDefault(); $(this).parent('div').remove(); x--;
                                })
                  });
$(document).ready(function() {
                  var max_fields      = 10;
                  var wrapper         = $(".container2");
                  var add_button      = $(".add_form_field2");
                  
                  var x = 1;
                  $(add_button).click(function(e){
                                      e.preventDefault();
                                      if(x < max_fields){
                                      x++;
                                      $(wrapper).append('<div><input type="text" name="offers[]"/><a href="#" class="delete">Delete</a></div>'); //add input box
                                      }
                                      else
                                      {
                                      alert('You Reached the limits')
                                      }
                                      });
                  
                  $(wrapper).on("click",".delete", function(e){
                                e.preventDefault(); $(this).parent('div').remove(); x--;
                                })
                  });
