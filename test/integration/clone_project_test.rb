require 'test_helper'
require_relative 'base_integration_test'

class CloneProjectTest < IntegrationTest
  def set_cell(row, col, value)
    find(:css, ".slick-row:nth-child(#{row + 1})>.slick-cell.l#{col}").double_click
    find(:css, ".slick-row:nth-child(#{row + 1})>.slick-cell.l#{col}>input").set value
  end

  # Note, currectly does not verify data is cloned correct, just that the sets are cloned
  test 'nixon clones kates project' do
    # #############SETUP#############
    login('kcarcia@cs.uml.edu', '12345')

    click_on 'Projects'

    find('#create-project-fab-button').click
    find('#project_title').set('Das Cloning Projekt')
    click_on 'Create Project'

    find('#manual_fields').click
    click_on 'Add Number'
    assert page.has_content?('Number'), 'Number field is there'
    find('#fields_form_submit').click

    click_on 'Manual Entry'
    fill_in 'Data Set Name', with: 'I Like Clones'
    find('#edit_table_add_1').click
    set_cell(0, 0, 47)
    find('#edit_table_save_2').click

    # This line forces Capybara to wait until the data set is saved. Otherwise,
    #   the next line will intermittently fail.
    find('#title-name')

    assert page.has_content?('I Like Clones'), 'Save should succeed'
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    drop_in_dropzone img_path
    assert page.has_content?('nerdboy.jpg'), 'File should be in list'

    click_on 'Das Cloning Projekt'
    img_path = Rails.root.join('test', 'CSVs', 'test.pdf')
    drop_in_dropzone img_path
    assert page.has_content?('test.pdf'), 'File should be in list'

    logout
    # ###########CLONE###############
    login 'nixon@whitehouse.gov', '12345'

    click_on 'Projects'

    click_on 'Das Cloning Projekt'

    visit URI.parse(current_url).to_s + '/clone'
    find('#clone_datasets').set(true)
    find('#project_name').set('Cloned with Data')
    click_on 'Clone Project'

    assert page.has_content?('nerdboy.jpg'), 'File should be in list'
    assert page.has_content?('test.pdf'), 'File should be in list'
    assert page.has_content?('I Like Clones'), 'Data set should be in list'
    assert find('#fields').has_no_content?('Setup Manually')

    page.find('.dataset').click_on 'Delete'
    page.driver.browser.accept_js_confirms

    page.find('#edit-project-button').click
    click_on 'Delete Project'
    page.driver.browser.accept_js_confirms

    click_on 'Projects'
    assert page.has_no_content?('Cloned with Data'), 'Project Removed from List'
  end
end
