Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file } # loads libraries from lib folder

require 'rbconfig' 

class App
    def initialize()
        is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/) # check if running windows - different command for clearing screen
        if is_windows
            @clear_cmd = 'cls'
        else
            @clear_cmd = 'clear'
        end
        @albums = []
        @album_editing = 0
    end

    def clearScreen()
        system(@clear_cmd) 
    end

    def displayMenuName(menu_name)
        puts("\033[1m  #{menu_name}  \033[0m")
    end

    def waitEnter
        readString('Press ENTER to continue...')
    end

    def displayOptions(options, exit_option)
        options.each_with_index do |(key, value), index|
            puts("#{(index + 1).to_s} - #{key}")
        end
        if exit_option
            puts("#{(options.length+1).to_s} - Exit")  
        end
    end

    def validateChoice(choice, options_length, exit_option=false)
        offset = 0
        if exit_option
            offset = 1
        end
        return choice > 0 && choice <= (options_length + offset)
    end

    def loop(menu_name, options, exit_option=true)
        input_valid = true
        while true
            begin
                choice = 0
                validation = false
                until validation
                    clearScreen()
                    displayMenuName(menu_name)
                    displayOptions(options, exit_option)
                    if input_valid == false
                        puts('Please select a valid option!')
                    end
                    choice = readInteger('Option: ')
                    validation = validateChoice(choice, options.length, exit_option)
                    if !validation 
                        input_valid = false 
                    end
                end

                if choice == options.length + 1 && exit_option
                    break
                end
                
                options[options.keys[choice-1]].()

                if !exit_option
                    break
                end

                input_valid = true
            rescue# will always get executed
                # puts(exception)
                # waitEnter()
                input_valid = false
                retry
            end
        end 
    end

    def start()
        menu_name = 'Main menu'
        options = {
            'Read in Albums' => method(:readInAlbums),
            'Display Album Info' => method(:displayAlbumInfo),
            'Play Album' => method(:playAlbums),
            'Update Album' => method(:updateAlbums)
        }   
        loop(menu_name, options)
    end

    def readInAlbums()
        clearScreen()
        menu_name = 'Read in Albums'
        displayMenuName(menu_name)
        file_path = readString('File path: ')
        while true
            if !File.file?(file_path)
                clearScreen()
                displayMenuName(menu_name)
                puts("File does not exists: `#{file_path}`\n")
                file_path = readString('File path: ')
            else
                @albums = loadAlbums(file_path)
                clearScreen()
                displayMenuName(menu_name)
                puts("Successfully loaded #{@albums.length} albums\n")
                for album in @albums do
                    puts("#{album.name} by #{album.artist}")
                end
                waitEnter()
                break
            end
        end
    end
    
    def displayAlbumInfo()
        menu_name = 'Display Album Info'
        options = {
            'Display All' => method(:displayAllAlbums),
            'Display by Genre' => method(:displayByGenres),
        }   
        loop(menu_name, options, exit_option = false)
    end

    def displayAlbum(album, index)
        puts('-'*12)
        puts("Album ID: #{(index+1).to_s}")
        puts("> #{album.name.upcase()} by #{album.artist}")
        puts(album.year)
        genre_string = getGenreString(album.genres)
        puts("-- #{genre_string} --")
        puts('Tracks:')
        for track in album.tracks do
            puts("* #{track.name}")
        end
        puts('-'*12)
    end

    def displayAlbumBrief(album, index)
        puts('-'*12)
        puts("Album ID: #{(index+1).to_s}")
        puts("> #{album.name.upcase()} by #{album.artist}")
        puts(album.year)
        puts('-'*12)
    end

    def displayAllAlbums()
        menu_name = 'Albums'
        clearScreen()
        displayMenuName(menu_name)
        if @albums.length == 0
            puts('No albums loaded!')
        else
            @albums.each_with_index do |album, index|
                displayAlbum(album, index)
            end
        end
        waitEnter()
    end
    
    def displayByGenres()
        genres = fetchAllGenres()
        menu_name = 'Display By Genres'
        begin
            choice = 0
            validation = false
            until validation
                clearScreen()
                displayMenuName(menu_name)        
                genres.each_with_index do |genre, index|
                    puts("#{index+1} - #{genre}")
                end
                choice = readInteger('Option: ')
                validation = validateChoice(choice, genres.length, exit_option=false)
            end
        rescue Exception => e
            puts(e)
            waitEnter()
            retry
        end
        clearScreen()
        menu_name = "Displaying albums wth genre #{getGenre(choice-1)}"
        displayMenuName(menu_name)
        valid_albums = searchGenre(choice, @albums)
        if valid_albums.length == 0
            puts('No album with chosen genre!')
        else
            valid_albums.each_with_index do |album, index|
                displayAlbum(album, index)
            end
        end
        waitEnter()
    end

    def playAlbums()
        menu_name = 'Play albums'
        if @albums.length == 0
            clearScreen()
            displayMenuName(menu_name)        
            puts('No albums loaded!')
            waitEnter()
            return
        end
        begin
            choice = 0
            validation = false
            until validation
                clearScreen()
                displayMenuName(menu_name)        
                @albums.each_with_index do |album, index|
                    displayAlbumBrief(album, index)
                end
                choice = readInteger('Option: ')
                validation = validateChoice(choice, @albums.length)
            end
        rescue Exception => e
            puts(e)
            retry
        end
        album_index = choice - 1
        playAlbum(album_index)
    end

    def playAlbum(index)
        # @artist = artist
        # @name = name
        # @year = year
        # @genres = genres
        # @tracks = tracks
        menu_name = "Select track from #{@albums[@album_editing].name} by #{@albums[@album_editing].artist} to play"
        begin
            choice = 0
            validation = false
            until validation
                clearScreen()
                displayMenuName(menu_name)        
                @albums[@album_editing].tracks.each_with_index do |track, index|
                    puts("#{index+1} - #{track.name}")
                end
                choice = readInteger('Option: ')
                validation = validateChoice(choice, @albums.length)
            end
        rescue Exception => e
            puts(e)
            retry
        end
        playTrack(choice-1)
    end

    def playTrack(index)
        current_track = @albums[@album_editing].tracks[index]
        menu_name = "Playing track: #{current_track.name}"
        clearScreen()
        displayMenuName(menu_name)
        waitEnter()
    end

        

    def updateAlbums()
        menu_name = 'Update albums'
        if @albums.length == 0
            clearScreen()
            displayMenuName(menu_name)        
            puts('No albums loaded!')
            waitEnter()
            return
        end
        begin
            choice = 0
            validation = false
            until validation
                clearScreen()
                displayMenuName(menu_name)        
                @albums.each_with_index do |album, index|
                    displayAlbumBrief(album, index)
                end
                choice = readInteger('Option: ')
                validation = validateChoice(choice, @albums.length)
            end
        rescue Exception => e
            puts(e)
            retry
        end
        album_index = choice - 1
        updateAlbum(album_index)
    end

    def updateAlbum(index)
        # @artist = artist
        # @name = name
        # @year = year
        # @genres = genres
        # @tracks = tracks
        menu_name = "Editing #{@albums[@album_editing].name} by #{@albums[@album_editing].artist}"
        options = {
            'Update artist' => method(:updateArtist),
            'Update name' => method(:updateName),
            'Update year' => method(:updateYear),
            'Update genres' => method(:updateGenres),
            'Update tracks' => method(:updateTracks)
        }
        loop(menu_name, options, exit_option=false)
    end

    def updateArtist()
        menu_name = "Current artist: #{@albums[@album_editing].artist}"
        clearScreen()
        displayMenuName(menu_name)
        string = readString('Enter new artist name:')
        @albums[@album_editing].artist = string
    end

    def updateName()
        menu_name = "Current name: #{@albums[@album_editing].name}"
        clearScreen()
        displayMenuName(menu_name)
        string = readString('Enter new name:')
        @albums[@album_editing].name = string
    end

    def updateYear()
        menu_name = "Current year: #{@albums[@album_editing].year}"
        clearScreen()
        displayMenuName(menu_name)
        string = readString('Enter new year:')
        @albums[@album_editing].year = string
    end

    def updateGenres()
        menu_name = "Current genres: #{getGenreString(@albums[@album_editing].genres)}"
        clearScreen()
        displayMenuName(menu_name)
        fetchAllGenres().each_with_index do |genre, index|
            puts("#{(index + 1).to_s} - #{genre}")
        end
        string = readString('Enter new genres: (seperated by comma - e.g. 1,2,3,4,5)')
        genres = []
        string.split(',',-1).map { |value| 
            genres.append(value.to_i)
            next
        }
        @albums[@album_editing].genres = genres
    end

    def updateTracks()
        menu_name = "Current tracks"
        begin
            choice = 0
            validation = false
            until validation
                clearScreen()
                displayMenuName(menu_name)        
                @albums[@album_editing].tracks.each_with_index do |track, index|
                    puts("#{index+1} - #{track.name}")
                end
                choice = readInteger('Option: ')
                validation = validateChoice(choice, @albums.length)
            end
        rescue Exception => e
            puts(e)
            retry
        end
        updateTrack(choice-1)
    end

    def updateTrack(index)
        current_track = @albums[@album_editing].tracks[index]
        menu_name = "Current track: #{current_track.name}"
        clearScreen()
        displayMenuName(menu_name)
        puts("Path: #{current_track.path}")
        name = readString('Enter new name:')
        path = readString('Enter new path:')
        @albums[@album_editing].tracks[index].name = name
        @albums[@album_editing].tracks[index].path = path
    end
end

def main()
    app = App.new()
    app.start()
end
  
main()
