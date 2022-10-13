
# Display the prompt and return the read string
def readString prompt
	puts prompt
	value = gets.chomp
end

# Display the prompt and return the read float
def readFloat prompt
	value = readString(prompt)
	value.to_f
end

# Display the prompt and return the read integer
def readInteger prompt
	value = readString(prompt)
	value.to_i
end

# Read an integer between min and max, prompting with the string provided

def readIntegerInRange(prompt, min, max)
	value = readInteger(prompt)
	while (value < min or value > max)
		puts "Please enter a value between " + min.to_s + " and " + max.to_s + ": "
		value = readInteger(prompt);
	end
	value
end

# Display the prompt and return the read Boolean

def readBoolean prompt
	value = readString(prompt)
	case value
	when 'y', 'yes', 'Yes', 'YES'
		true
	else
		false
	end
end

# Test the functions above
=begin
def main
	puts "String entered is: " + readString("Enter a String: ")
	puts "Boolean is: " + read_boolean("Enter yes or no:").to_s
	puts "Float is: " + readFloat("Enter a floating point number: ").to_s
	puts "Integer is: " + readInteger_in_range("Enter an integer between 3 and 6: ", 3, 6).to_s
end

main
=end
