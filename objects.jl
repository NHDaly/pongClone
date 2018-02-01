abstract type GameObject end

struct WorldPos  # 0,0 == middle
    x::Float64
    y::Float64
end
struct Vector2D
    x::Float64
    y::Float64
end
import Base.*, Base./, Base.-, Base.+
+(a::Vector2D, b::Vector2D) = Vector2D(a.x+b.x, a.y+b.y)
-(a::Vector2D, b::Vector2D) = Vector2D(a.x-b.x, a.y-b.y)
*(a::Vector2D, x::Number) = Vector2D(a.x*x, a.y*x)
*(x::Number, a::Vector2D) = a*x
/(a::Vector2D, x::Number) = Vector2D(a.x/x, a.y/x)
+(a::WorldPos, b::Vector2D) = WorldPos(a.x+b.x, a.y+b.y)
-(a::WorldPos, b::Vector2D) = WorldPos(a.x-b.x, a.y-b.y)
+(a::Vector2D, b::WorldPos) = WorldPos(a.x+b.x, a.y+b.y)
-(a::Vector2D, b::WorldPos) = WorldPos(a.x-b.x, a.y-b.y)
-(a::WorldPos, b::WorldPos) = Vector2D(a.x-b.x, a.y-b.y)
-(x::WorldPos) = WorldPos(-x.x, -x.y)
-(x::Vector2D) = Vector2D(-x.x, -x.y)

const ballWidth=10
mutable struct Ball
    pos::WorldPos
    vel::Vector2D
end
mutable struct Paddle
    pos::WorldPos
    length
end

collide!(a::Ball, b::Paddle) = collide!(b,a)
function collide!(p::Paddle, b::Ball)
    xIncr = 100
    xSign = 1
    if b.pos.x - p.pos.x > p.length/4; # In right quarter
        if b.vel.x < 0 ; xSign=-1; end
    elseif b.pos.x - p.pos.x < -p.length/4; # In left
        xIncr *=-1; if b.vel.x > 0 ; xSign=-1; end
    else xIncr = 0;
    end
    b.vel = Vector2D(b.vel.x * xSign + xIncr, -b.vel.y)
end


struct Line
     a::WorldPos
     b::WorldPos
end
""" Will they collide on the next update?"""
willCollide(b::Ball, p::Paddle, dt) = willCollide(p,b,dt)
function willCollide(p::Paddle, b::Ball, dt)
    if (abs(p.pos.x - b.pos.x) <= (p.length/2.+ballWidth/2))
        l = Line(b.pos, b.pos+b.vel*dt) # If next update will bring collision.
        return isColliding(p, l, ballWidth)
    else
        return false
    end
end
""" Did they collide b/c of previous update?"""
didCollide(b::Ball, p::Paddle, dt) = didCollide(p,b,dt)
function didCollide(p::Paddle, b::Ball, dt)
    if (abs(p.pos.x - b.pos.x) <= (p.length/2.+ballWidth/2))
        l = Line(b.pos-b.vel*dt, b.pos) # Did last update bring collision.
        return isColliding(p, l, ballWidth)
    else
        return false
    end
end
function isColliding(p::Paddle, l::Line, width)
    v = l.b - l.a
    if v.y != 0
        c0 = (p.pos.y - l.a.y) / v.y
        if !(0. <= c0 <= 1.) return false end
        lc0 = (c0*v + l.a)
    else
        lc0 = l.a
        if (l.a.y != p.pos.y) return false end
    end
    return abs(lc0.x - p.pos.x) <= (p.length/2.0 + width/2.)
end

function update!(x::Ball, dt)
    x.pos = x.pos + (x.vel * dt)
end
function update!(x::Paddle, keys, dt)
    if (keys.leftDown)
        x.pos = WorldPos(x.pos.x - (paddleSpeed * dt), x.pos.y)
    end
    if (keys.rightDown)
        x.pos = WorldPos(x.pos.x + (paddleSpeed * dt), x.pos.y)
    end
end