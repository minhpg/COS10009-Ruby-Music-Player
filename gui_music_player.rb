require 'rubygems'
require 'gosu'
require 'audioinfo'

Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file } # loads libraries from lib folder

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFFFFFF)

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600

module Layer
  BACKGROUND, PLAYER, UI = *0..2
end

class MusicPlayer < Gosu::Window

    def initialize
	    super SCREEN_WIDTH, SCREEN_HEIGHT
	    self.caption = "Music Player"

        @albums = loadAlbums('input.txt')
        puts(@albums)
		# Reads in an array of albums from a file and then prints all the albums in the
		# array to the terminal
        @margin_right = -50
        @margin_left = +50
        @gap = 30
        @margin_top = 50
        @grid_y_start = @margin_top
        @current_scroll = 0

        @album_index_active
        @album_index_hover
        @track_index_active
        @track_index_hover

        @audio_length = 0
        @current_audio_time = 0
        @current_progress = 0
        @audio_length_formatted

        @track_history = []

        @image_color = Gosu::Color.new(0xFFFFFFFF)

        initializeFonts()
        initializeControls()
	end

    def initializeFonts()
        @font = Gosu::Font.new(self, 'font/Roboto/Roboto-Regular.ttf', 15)
        @font_black = Gosu::Font.new(self, 'font/Roboto/Roboto-Black.ttf', 15)
        @font_medium = Gosu::Font.new(self, 'font/Roboto/Roboto-Medium.ttf', 15)
        @font_light = Gosu::Font.new(self, 'font/Roboto/Roboto-Light.ttf', 15)
        @font_thin = Gosu::Font.new(self, 'font/Roboto/Roboto-Thin.ttf', 15)
        @font_bold = Gosu::Font.new(self, 'font/Roboto/Roboto-Bold.ttf', 15)

        @font_black_35 = Gosu::Font.new(self, 'font/Roboto/Roboto-Black.ttf', 35)
        @font_light_25 = Gosu::Font.new(self, 'font/Roboto/Roboto-Light.ttf', 25)
        @font_light_20 = Gosu::Font.new(self, 'font/Roboto/Roboto-Light.ttf', 20)

    end

    def secondsToMS(sec)
        [sec / 60 % 60, sec % 60].map{|t| t.round.to_s.rjust(2,'0')}.join(':')
    end

    def startTrack()
        @track_history.append({
            'album' => @album_index_active,
            'track' => @track_index_active
        })
        album = @albums[@album_index_active]
        track = album.tracks[@track_index_active]
        track_path = track.path.chomp
        full_path = File.join(Dir.pwd, track_path)
        begin
            @audio_length = 0
            @current_audio_time = 0
            @current_progress = 0
            @audio_length_formatted = 0
            AudioInfo.open(full_path) do |info|
                @audio_length = info.length   # playing time of the file
                @audio_length_formatted = secondsToMS(@audio_length)
            end
            @song = Gosu::Song.new(full_path)
            @song.play(false)
        rescue Exception => e
            puts(e)
        end
    end

    def playTrack()
        if @song
            if @song.paused?
                @song.play(false)
            else
                pauseTrack()
            end
        end
    end

    def pauseTrack()
        @song.pause
    end

    def prevTrack()
        # if @track_history.length() > 0
        #     i
        # end
    end

    def nextTrack()

    end

    def updateProgress()
        if @song
            paused = @song.paused? 
        else
            paused = true
        end
        if !paused
            @current_audio_time += self.update_interval / 1000
        end
    end


    def drawBackground
        draw_rect(0,0, SCREEN_WIDTH, SCREEN_HEIGHT, Gosu::Color::WHITE, Layer::BACKGROUND)
    end

    def initializeControls
        # declare positioning variables
        bar_height = 50
        bar_width = SCREEN_WIDTH
        bar_y_start = SCREEN_HEIGHT - bar_height
        bar_x_start = 0


        #draw bottom bar
        @bottom_bar = Dimension.new(
            bar_x_start, bar_y_start, bar_width, bar_height
        )

        #draw controls
        controls_width = 50
        button_x_start = bar_x_start + @margin_left
        

        @reverse_button = Dimension.new(
            button_x_start,
            bar_y_start,
            controls_width,
            bar_height
        )

        @play_button = Dimension.new(
            button_x_start + controls_width * 1,
            bar_y_start,
            controls_width,
            bar_height
        )

        @forward_button = Dimension.new(
            button_x_start + controls_width * 2,
            bar_y_start,
            controls_width,
            bar_height
        )
    end

    def drawBottomBar
        bar_color = Colors::RED_SALSA
        bar_layer = Layer::PLAYER
        text_color = Gosu::Color::BLACK

        draw_rect(@bottom_bar.x, @bottom_bar.y, @bottom_bar.width, @bottom_bar.height, bar_color, bar_layer)

        button_y = @reverse_button.y
        button_width = @reverse_button.width
        button_height = @reverse_button.height

        drawButton(@reverse_button.x, button_y, button_width, button_height, bar_color, bar_layer, text="<<", Gosu::Color::BLACK)
        if @song
            paused = @song.paused? 
        else
            paused = true
        end
        if !paused
            play_button_text = "II"
        else
            play_button_text = "|>"
        end
        drawButton(@play_button.x, button_y, button_width, button_height, bar_color, bar_layer, text=play_button_text, Gosu::Color::BLACK)
        drawButton(@forward_button.x, button_y, button_width, button_height, bar_color, bar_layer, text=">>", Gosu::Color::BLACK)

        button_x_start = @reverse_button.x
        controls_width = button_width
        bar_width = @bottom_bar.width
        bar_y_start = @bottom_bar.y
        bar_height = @bottom_bar.height

        #draw progress bar
        progress_bar_width = 350
        progress_bar_start = button_x_start + controls_width * 3
        track_info_start = bar_width - 200
        if @audio_length > 0
            @current_progress = @current_audio_time / @audio_length
        end

        drawProgressBar(progress_bar_start, bar_y_start, progress_bar_width, bar_height, bar_layer, @current_progress, text_color)
        drawTrackInfo(track_info_start, bar_y_start, 40, bar_height, bar_layer)
    end

    def drawButton(x, y, width, height, color, layer, text, text_color)
        draw_rect(x, y, width, height, color, layer)
        @font_black.draw_text(text, x, y + height / 2 - 10 , layer + 1, scale_x=1, scale_y=1, text_color)
    end

    def drawProgressBar(x, y, width, height, layer, current_progress, text_color)
        progress_bar_height = 5
        progress_bar_width = width - 100
        margin_top = height / 2 - 5
        y = y + margin_top
        @font.draw_text(secondsToMS(@current_audio_time), x, y-3, layer + 1, scale_x=1, scale_y=1, text_color)
        @font.draw_text(@audio_length_formatted, x + progress_bar_width + 60, y-3 , layer + 1, scale_x=1, scale_y=1, text_color)
        draw_rect(x + 50, y, progress_bar_width, progress_bar_height, Colors::ORCHID_PINK, layer)
        draw_rect(x + 50, y, progress_bar_width*current_progress, progress_bar_height, Colors::DARK_SIENNA, layer + 1)
    end

    def drawTrackInfo(x, y, image_width, height, layer)
        y_image = y + ((height - image_width) / 2 )

        info_text_start = x + image_width + 10

        if @album_index_active && @track_index_active
            album = @albums[@album_index_active]
            track = album.tracks[@track_index_active]
            album_artist = album.artist
            track_name = track.name
            album.artwork.draw_as_quad(x, y_image, @image_color,
                x+image_width, y_image, @image_color,
                x, y_image+image_width, @image_color,
                x+image_width, y_image+image_width, @image_color,
                layer)
        else
            album_artist = 'Not playing'
            track_name = 'Not playing'
        end
        @font.draw_text(album_artist,info_text_start  , y + height / 3 -5 , layer + 1, scale_x=1, scale_y=1, Gosu::Color::BLACK)
        @font_bold.draw_text(track_name, info_text_start, y + height / 3 + 10 , layer + 1, scale_x=1, scale_y=1, Gosu::Color::BLACK)

    end

    def drawGrid()
        # @margin_left
        # @margin_right
        #create grid box
        album_per_row = 4
        max_albums_screen = 8
        grid_width = SCREEN_WIDTH - @margin_left + @margin_right
        album_width = ( grid_width - @gap * (album_per_row - 1) ) / album_per_row
        line = 0
        start_x = @margin_left
        start_y = @grid_y_start + @margin_top
        album_layer = Layer::BACKGROUND
        album_height = album_width + 20
        @albums.each_with_index do |album, index|
            grid_row_pos = index % 4
            active = (index == @album_index_active)
            hover = (index == @album_index_hover)
            @albums[index].dimension.setX(start_x + album_width * grid_row_pos + @gap * grid_row_pos)
            @albums[index].dimension.setY(start_y + line * (@gap + album_height))
            @albums[index].dimension.setWidth(album_width)
            @albums[index].dimension.setHeight(album_height)
            drawAlbum(album, album_layer, hover, active)
            if grid_row_pos == 3
                line += 1
            end
        end
    end

    def drawAlbum(album, layer, hover, active)
        x = album.dimension.x
        y = album.dimension.y
        width = album.dimension.width
        height = album.dimension.height
        album.artwork.draw_as_quad(x, y, @image_color,
            x+width, y, @image_color,
            x, y+width, @image_color,
            x+width, y+width, @image_color,
            layer )
        hover ? text_color = Gosu::Color::RED : text_color = Gosu::Color::BLACK
        @font_bold.draw_text(album.name, x, y + width + 5, layer, scale_x=1, scale_y=1, text_color)
        @font_light.draw_text(album.artist, x, y + width + 20, layer, scale_x=0.9, scale_y=0.9, Gosu::Color::GRAY)
    end

    def drawAlbumDetail()
        height = 300
        true_height = height - @gap
        # grid_y_start_original = @grid_y_start
        layer =  Layer::UI 
        if @album_index_active
            album = @albums[@album_index_active]
            start_x = @margin_left
            start_y = @gap + @current_scroll
            @grid_y_start = height + @current_scroll
            true_width = SCREEN_WIDTH -  @margin_left * 2
            draw_rect(start_x, start_y, true_width, true_height, Gosu::Color::WHITE, layer)
            padding = 20
            image_x = start_x + padding
            image_y = start_y + padding
            image_width = true_height
            album.artwork.draw_as_quad(image_x, image_y, @image_color,
                image_x+image_width, image_y, @image_color,
                image_x, image_y+image_width, @image_color,
                image_x+image_width, image_y+image_width, @image_color,
                layer )
            image_margin_right = 20
            album_name_scale = 1
            album_artist_scale = 1
            info_start_x = image_x + image_width + image_margin_right
                
            @font_black_35.draw_text(album.name, info_start_x, image_y, layer, scale_x=album_name_scale, scale_y=album_name_scale, Gosu::Color::BLACK)
            @font_light_25.draw_text(album.artist, info_start_x + 2, image_y +30, layer, scale_x=album_artist_scale, scale_y=album_artist_scale, Gosu::Color::GRAY)

            track_start_y = image_y + 75
            track_gap = 20
            track_width = true_width - info_start_x
            album.tracks.each_with_index do |track, index|
                track_item_start_y = track_start_y + track_gap * index
                @albums[@album_index_active].tracks[index].dimension.setX(info_start_x)
                @albums[@album_index_active].tracks[index].dimension.setY(track_item_start_y)
                @albums[@album_index_active].tracks[index].dimension.setWidth(track_width)
                @albums[@album_index_active].tracks[index].dimension.setHeight(track_gap)

                index == @track_index_hover ? text_color = Gosu::Color::RED : text_color = Gosu::Color::BLACK

                draw_rect(info_start_x, track_item_start_y, track_width, track_gap, Gosu::Color::WHITE, layer)
                @font_light_20.draw_text("#{index+1}. #{track.name}", info_start_x, track_item_start_y, layer, scale_x=album_name_scale, scale_y=album_name_scale, text_color)
            end
        else
            @grid_y_start = @current_scroll
        end
    end

    # Not used? Everything depends on mouse actions.

    # Detects if a 'mouse sensitive' area has been clicked on
    # i.e either an album or a track. returns true or false

    def checkAlbumHover()
        # complete this code
        # mouse_x mouse_y
        @albums.map.with_index { |album, index|
            dimension = album.dimension
            x1 = dimension.x
            y1 = dimension.y
            x2 = dimension.x + dimension.width
            y3 = dimension.y + dimension.height
            if mouse_x > x1 && mouse_x < x2 && mouse_y > y1 && mouse_y < y3
                return index
            end
            }
        return
    end

    def checkTrackHover()
        # complete this code
        # mouse_x mouse_y
        if @album_index_active
            @albums[@album_index_active].tracks.map.with_index { |track, index|
                dimension = track.dimension
                x1 = dimension.x
                y1 = dimension.y
                x2 = dimension.x + dimension.width
                y3 = dimension.y + dimension.height
                if mouse_x > x1 && mouse_x < x2 && mouse_y > y1 && mouse_y < y3
                    return index
                end
                }
        end
        return
    end

    def mouseOnComponent(dimension)
        x1 = dimension.x
        y1 = dimension.y
        x2 = dimension.x + dimension.width
        y3 = dimension.y + dimension.height
        if mouse_x > x1 && mouse_x < x2 && mouse_y > y1 && mouse_y < y3
            return true
        end
        return false
    end

    def update
        @album_index_hover = checkAlbumHover()
        @track_index_hover = checkTrackHover()
        updateProgress()
    end

    # Draws the album images and the track list for the selected album

    def draw
        # Complete the missing code
        drawBackground
        drawBottomBar
        drawAlbumDetail
        drawGrid

    end

    def needs_cursor?; true; end

    # If the button area (rectangle) has been clicked on change the background color
    # also store the mouse_x and mouse_y attributes that we 'inherit' from Gosu
    # you will learn about inheritance in the OOP unit - for now just accept that
    # these are available and filled with the latest x and y locations of the mouse click.

    def button_down(id)
        case id
        when Gosu::MsLeft
            play_hover = mouseOnComponent(@play_button)
            reverse_hover = mouseOnComponent(@reverse_button)
            forward_hover = mouseOnComponent(@forward_button)
            if play_hover
                playTrack()
            end
            if reverse_hover
                prevTrack()
            end 
            if forward_hover
                nextTrack()
            end
            controls_clicked = (play_hover || reverse_hover || forward_hover)
            if !controls_clicked
                @track_index_active = checkTrackHover()
                if !@track_index_active
                    @album_index_active = checkAlbumHover()
                end
                if @track_index_active
                    startTrack()
                end
                if !@album_index_active && !@track_index_active
                    
                end
            end

        when Gosu::MS_WHEEL_DOWN
            puts(@grid_y_start)
                for i in 0..5000
                    @current_scroll  -= 0.01
                end

        when Gosu::MS_WHEEL_UP    
            puts(@grid_y_start)
            if @current_scroll < 0
                for i in 0..5000
                    @current_scroll  += 0.01
                end
            end
        end
    end

end

# Show is a method that loops through update and draw

MusicPlayer.new.show if __FILE__ == $0