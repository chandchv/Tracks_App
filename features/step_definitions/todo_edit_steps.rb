####### MARK (UN)COMPLETE #######

When /^I mark "([^"]*)" as complete$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  check "mark_complete_#{todo.id}"

  wait_for_ajax
end

When /^I mark "([^"]*)" as uncompleted$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  uncheck "mark_complete_#{todo.id}"

  wait_for_ajax
end

When /^I mark the complete todo "([^"]*)" active$/ do |action_description|
  step "I mark \"#{action_description}\" as uncompleted"
end

####### (UN)STARRING #######

When /^I star the action "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  xpath_unstarred = "//div[@id='line_todo_#{todo.id}']//img[@class='todo_star']"
  xpath_starred = "//div[@id='line_todo_#{todo.id}']//img[@class='todo_star starred']"

  page.should have_xpath(xpath_unstarred)

  star_img = "//img[@id='star_img_#{todo.id}']"
  page.find(:xpath, star_img).click
  
  wait_for_ajax
  wait_for_animations_to_end
  
  page.should have_xpath(xpath_starred)
end

When /^I unstar the action "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  xpath_unstarred = "//div[@id='line_todo_#{todo.id}']//img[@class='todo_star']"
  xpath_starred = "//div[@id='line_todo_#{todo.id}']//img[@class='todo_star starred']"

  page.should have_xpath(xpath_starred)

  star_img = "//img[@id='star_img_#{todo.id}']"
  page.find(:xpath, star_img).click
  
  page.should have_xpath(xpath_unstarred)
end

####### Editing a todo using Edit Form #######

When /I change the (.*) field of "([^\"]*)" to "([^\"]*)"$/ do |field_name, todo_name, new_value|
  todo = @current_user.todos.find_by_description(todo_name)
  todo.should_not be_nil

  open_edit_form_for(todo)
  within "form.edit_todo_form" do
    fill_in "#{field_name}", :with => new_value
  end
  submit_edit_todo_form(todo)
end

When /^I edit the context of "([^"]*)" to "([^"]*)"$/ do |todo_name, context_new_name|
  step "I change the context_name field of \"#{todo_name}\" to \"#{context_new_name}\""
end

When /^I edit the project of "([^"]*)" to "([^"]*)"$/ do |todo_name, project_new_name|
  step "I change the project_name field of \"#{todo_name}\" to \"#{project_new_name}\""
end

When /^I edit the description of "([^"]*)" to "([^"]*)"$/ do |action_description, new_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil
  
  open_edit_form_for(todo)
  fill_in "todo_description", :with => new_description
  submit_edit_todo_form(todo)
end

When /^I try to edit the description of "([^"]*)" to "([^"]*)"$/ do |action_description, new_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil
  
  open_edit_form_for(todo)
  fill_in "todo_description", :with => new_description
  submit_button_xpath = "//div[@id='edit_todo_#{todo.id}']//button[@id='submit_todo_#{todo.id}']"
  page.find(:xpath, submit_button_xpath).click
  wait_for_ajax
  # do not wait for form to disappear to be able to test failures
end

When /^I edit the due date of "([^"]*)" to "([^"]*)"$/ do |action_description, date|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  open_edit_form_for(todo)
  fill_in "due_todo_#{todo.id}", :with => date
  submit_edit_todo_form(todo)
end

When /^I edit the due date of "([^"]*)" to tomorrow$/ do |action_description|
  date = format_date(Time.zone.now + 1.day)
  step "I edit the due date of \"#{action_description}\" to \"#{date}\""
end

When /^I edit the due date of "([^"]*)" to next month$/ do  |action_description|
  date = format_date(Time.zone.now + 1.month)
  step "I edit the due date of \"#{action_description}\" to \"#{date}\""
end

When /^I clear the due date of "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil
  
  open_edit_form_for(todo)
  within "div#edit_todo_#{todo.id}" do
    find("a#due_x_todo_#{todo.id}").click
    wait_until do
      find("input#due_todo_#{todo.id}").value == ""
    end
  end
  submit_edit_todo_form(todo)
end

When /^I edit the show from date of "([^"]*)" to next month$/ do  |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil
  
  open_edit_form_for(todo)
  fill_in "show_from_todo_#{todo.id}", :with => format_date(todo.created_at + 1.month)
  submit_edit_todo_form(todo)
end

When /^I remove the show from date from "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  open_edit_form_for(todo)
  page.find(:xpath, "//div[@id='edit_todo_#{todo.id}']//a[@id='show_from_x_todo_#{todo.id}']/img").click
  submit_edit_todo_form(todo)
end

When /^I clear the show from date of "([^"]*)"$/ do |action_description|
  step "I remove the show from date from \"#{action_description}\""
end

When /^I defer "([^"]*)" for 1 day$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  open_submenu_for(todo)
  page.should have_css("a#defer_1_todo_#{todo.id}", :visible=>true)
  click_link "defer_1_todo_#{todo.id}"

  wait_for_ajax
  wait_for_animations_to_end
end

When /^I edit the tags of "([^"]*)" to "([^"]*)"$/ do |action_description, tags|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  open_edit_form_for(todo)
  fill_in "tag_list", :with => tags
  submit_edit_todo_form(todo)
end

When /^I make a project of "([^"]*)"$/ do |action_description|
  todo = @current_user.todos.find_by_description(action_description)
  todo.should_not be_nil

  open_submenu_for(todo)
  page.should have_css("a#to_project_todo_#{todo.id}", :visible=>true)
  click_link "to_project_todo_#{todo.id}"

  page.should have_no_css("div#line_todo_#{todo.id}")
  wait_for_ajax
  wait_for_animations_to_end
end

####### THEN #######

Then /^I should see an error message$/ do
  error_block = "//form/div[@id='edit_error_status']"
  page.should have_xpath(error_block)
end