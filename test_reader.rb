require "minitest/autorun"
require "json"
require_relative "Reader"

class ReaderTest < Minitest::Test
  # Mock client data for testing
  CLIENTS = [
    { "full_name" => "Alice Bob", "email" => "alice.bob@example.com" },
    { "full_name" => "person 1", "email" => "person.1@example.com" },
    { "full_name" => "Person 3", "email" => "person3@example.com" },
    { "full_name" => "Alice Bob Cindy", "email" => "alice.bob@example.com" } # Duplicate email
  ].freeze

  CLIENTS_NO_DUPLICATE = [
    { "full_name" => "Alice Bob", "email" => "alice.bob@example.com" },
    { "full_name" => "person 1", "email" => "person.1@example.com" },
    { "full_name" => "Person 3", "email" => "person3@example.com" }
  ]

  # Setup method to run before each test
  def setup
    @temp_file = "temp_clients.json"
    File.write(@temp_file, JSON.dump(CLIENTS)) # Create the file with mock data
  end

  # Teardown method to run after each test
  def teardown
    File.delete(@temp_file) if File.exist?(@temp_file) # Clean up the temp file
  end

  def test_search_by_name_found
    ARGV.replace([@temp_file, "search", "lice"]) # Simulating ARGV as if passed via command line
    clients = load_clients(@temp_file)
    output = capture_io do
      reader
    end
    assert_includes output[0], "Alice Bob"
    assert_includes output[0], "Alice Bob Cindy"
  end

  def test_search_by_name_not_found
    ARGV.replace([@temp_file, "search", "nobody"])
    output = capture_io do
      reader
    end
    assert_includes output[0], "No clients found matching"
  end

  def test_find_duplicates_found
    ARGV.replace([@temp_file, "duplicate"])
    output = capture_io do
      reader
    end
    assert_includes output[0], "Duplicate email found: alice.bob@example.com"
  end

  def test_find_duplicates_not_found
    no_dup_file = "temp_no_dup_clients.json"
    File.write(no_dup_file, JSON.dump(CLIENTS_NO_DUPLICATE))
    ARGV.replace([no_dup_file, "duplicate"])
    output = capture_io do
      reader
    end
    assert_includes output[0], "No duplicate emails found."
    File.delete(no_dup_file) if File.exist?(no_dup_file)
  end
end