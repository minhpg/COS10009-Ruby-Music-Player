class Dimension

    attr_accessor :x, :y, :width, :height

    def initialize(
       x, y, width, height
    )
        @x = x
        @y = y
        @width = width
        @height = height
    end

    def setX(x)
        @x = x
    end
    
    def setY(y)
        @y = y
    end

    def setWidth(width)
        @width = width
    end

    def setHeight(height)
        @height = height
    end
end
