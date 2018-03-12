num_row = 10
num_column = 10
num_bombs = 5

=begin
methods...
=end

def generate_display (num_c, num_r) #generate display of "???"
	current_disp = []
	for y in 0...num_c
		row = ""
		for x in 0...num_r
			row += "?"
		end
		current_disp << row
	end
	return current_disp
end

def print_display(disp) #print display
	print "  x "
	for a in 0...disp[0].length #1st row of x numbs
		print "#{a%10}"
	end
	puts
	puts " y  "
	for b in 0...disp.length
		print " #{b%10}  "
		puts disp[b]
	end
end

def generate_bomb_cords(num_c, num_r, num_b)
	return nil if num_b >= (num_c * num_r)
	cords_list = []
	while cords_list.length <= num_b
		cords = [ rand(num_c), rand(num_r) ]
		next if cords_list.include?(cords)
		cords_list << cords
	end
	return cords_list
end

def update_map_ans_bombs(map, bomb_cords) #in game loop, removed last bomb_cords if player select bomb on 1st guess
	for a in 0...(bomb_cords.length)
		y = bomb_cords[a][0]
		x = bomb_cords[a][1]
		map[y][x] = "*"
	end
	return nil
end

def update_map_ans_num(map)
	for y in 0...map.length #check all cords in map
		for x in 0...map[0].length
			next if map[y][x] == "*" #need not change if bomb
			num_adj_bomb = 0 #bomb counter
			for y_3x3 in y-1..y+1 #count number of bombs in 8 squares around it
				next if (y_3x3 == -1) || (map[y_3x3] == nil) #skip if top or bottom row is outside map
				for x_3x3 in x-1..x+1
					next if (x_3x3 == -1) || (map[y_3x3][x_3x3] == nil) #skip if left or right is outside map
					num_adj_bomb += 1 if map[y_3x3][x_3x3] == "*"
				end
			end
			map[y][x] = num_adj_bomb.to_s
		end
	end
	return nil
end

def update_current_display(ans, disp, y_imp, x_imp)
	y = y_imp
	x = x_imp
	if ans[y][x] != "0"
		disp[y][x] = ans[y][x]
	else
		check_arr = [[y_imp,x_imp]]
		show_arr = []
		while check_arr.length > 0 #check and add all cords to show_arr
			y = check_arr[0][0]
			x = check_arr[0][1]
			show_arr << [y,x]
			for y_3x3 in y-1..y+1 #update 8 squares around it
				next if (y_3x3 == -1) || (ans[y_3x3] == nil) #skip if top or bottom row is outside map
				for x_3x3 in x-1..x+1
					next if (x_3x3 == -1) || (ans[y_3x3][x_3x3] == nil) #skip if left or right is outside map
					next if show_arr.include?([y_3x3,x_3x3])
					next if check_arr.include?([y_3x3,x_3x3])
					if ans[y_3x3][x_3x3] == "0"
						check_arr << [y_3x3,x_3x3]
					else
						show_arr << [y_3x3,x_3x3]
					end
				end
			end
			check_arr.shift
		end
		while show_arr.length > 0
			y = show_arr[0][0]
			x = show_arr[0][1]
			disp[y][x] = ans[y][x]
			show_arr.shift
		end
	end
	return nil
end

def count_num_question_marks(map) #if number of ? same as num bombs player wins
	num = 0
	for y in 0...map.length #check all cords in map
		for x in 0...map[0].length
			num += 1 if map[y][x] == "?"
		end
	end
	return num
end

=begin
initialise 1... generate variables
=end

bomb_cords = generate_bomb_cords(num_column, num_row,num_bombs)
current_display = generate_display(num_column, num_row)
map_answer = Marshal.load(Marshal.dump(current_display))

=begin
first input... #need first input to ensure first input isnt bomb
=end

while true
	puts
	print_display(current_display) #display first screen
	puts
	print "Input y coordinate: "
	y_imp = gets.to_i
	print "Input x coordinate: "
	x_imp = gets.to_i

	if (map_answer[y_imp] == nil) || (map_answer[y_imp][x_imp]==nil)
		puts "input coordinates within the range"
		next
	end

	if bomb_cords.include?([y_imp,x_imp])
		bomb_cords.delete([y_imp,x_imp])
	else 
		bomb_cords.pop()
	end
	break
end

=begin
initialise 2... generate variables
=end

update_map_ans_bombs(map_answer, bomb_cords)
update_map_ans_num(map_answer)

update_current_display(map_answer, current_display, y_imp, x_imp)

=begin
gameloop...
=end

while true

	puts
	print_display(current_display)
	puts
	print "Input y coordinate: "
	y_imp = gets.to_i
	print "Input x coordinate: "
	x_imp = gets.to_i
	
	if (map_answer[y_imp] == nil) || (map_answer[y_imp][x_imp]==nil)
		puts "input coordinates within the range"
		next
	end
	if current_display[y_imp][x_imp] != "?"
		puts "input an unexplored coordinate"
		next
	end
	
	if map_answer[y_imp][x_imp] == "*"
		puts "GAME OVER"
		exit
	end
	update_current_display(map_answer, current_display, y_imp, x_imp)
	
	break if num_bombs == count_num_question_marks(current_display)#break if win
end
print "You Win!"

=begin
to be done: 
1 win condition... half way thr (counting num ?) DONE!
2 lose condition... show bomb and print
3 get rid of extra bomb based on first imput DONE!
4 flag?
5 input num bombs and size
=end
