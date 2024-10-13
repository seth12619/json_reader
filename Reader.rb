require "json"

# Load JSON data
def load_clients(file_path)
  file = File.read(file_path)
  JSON.parse(file)
end

# Command to search clients by name
def search_by_name(clients, query)
  matching_clients = clients.select { |client| client["full_name"].downcase.include?(query.downcase) }
  if matching_clients.any?
    matching_clients.each do |client|
      puts "Name: #{client['full_name']}, Email: #{client['email']}"
    end
  else
    puts "No clients found matching '#{query}'."
  end
end

# Command to find duplicate emails
def find_duplicates(clients)
  email_count = clients.group_by { |client| client["email"] }
  duplicates = email_count.select { |_, v| v.size > 1 }

  if duplicates.any?
    duplicates.each do |email, clients|
      puts "Duplicate email found: #{email}"
      clients.each { |client| puts "Name: #{client['name']}, Email: #{client['email']}" }
    end
  else
    puts "No duplicate emails found."
  end
end

# Main program
# Command-line call - ruby Reader.rb clients.json function(search/duplicate) search_parameter
def reader
  inputs_array = ARGV
  clients = load_clients(inputs_array[0])
  if inputs_array[1] == "search"
    search_by_name(clients, inputs_array[2])
  elsif inputs_array [1] == "duplicate"
    find_duplicates(clients)
  else
    puts "Please provide a command with the following format: `ruby Reader.rb clients.json function(search/duplicate) search_parameter`"
  end
end

# Call the function to run when the file is executed directly
reader if __FILE__ == $0
