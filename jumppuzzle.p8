pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
lvls={}
lvindex=0
currentlv=nil
startgame=true
endgame=false

p={}
p.x=0
p.y=0

function _init()
 create_lvls()
 
	p.x=currentlv.spawn[1]
	p.y=currentlv.spawn[2]
	
	sfx(6)
end

function lvl_max_x(sx,sy)
	for x=sx,127 do
	 local cel=mget(x,sy)
	 if cel==0 then
	 	return x-1
	 end
	end
	
	return 127
end

function lvl_max_y(sx,sy)
	for y=sy,31 do
		local cel=mget(sx,y)
	 if cel==0 then
	 	return y-1
	 end
	end
	
	return 31
end

function find_cel(sx,sy,mx,my,cel)
 for x=sx,mx do
 	for y=sy,my do
 		if mget(x,y) == cel then
 			return {x,y}
 		end
 	end
 end	
end

function create_lvls()
	local sx=0
 local sy=0
 
 while sx<128 do
  local cel=mget(sx,y)
  if cel != 0 then
	 	local mx=lvl_max_x(sx,sy)
   local my=lvl_max_y(sx,sy)
 
	  local lvl={}
	  lvl.rect={sx,sy,mx,my}
	  lvl.spawn=find_cel(sx,sy,mx,my,19)
	  lvl.exit=find_cel(sx,sy,mx,my,20)
	
	  lvls[#lvls+1]=lvl
	  sx=mx
	 end
	 
	 sx=sx+1
	end
	
	lvindex=1
	currentlv=lvls[lvindex]
end

function _update()
	if endgame then
		return
	end

	if btnp(0) then
		move(-1,0)
	elseif btnp(1) then
	 move(1,0)
	elseif btnp(2) then
	 move(0,-1)
	elseif btnp(3) then
	 move(0,1)
	elseif btnp(❎) then
		p.x=currentlv.spawn[1]
	 p.y=currentlv.spawn[2]
	end
end

function move(dirx,diry)
	local mult=mget(p.x,p.y)
	if mult<1 or mult>5 then
		mult=1
	end
	
	local dcx=p.x+dirx*mult
	local dcy=p.y+diry*mult
	
	if dcx > currentlv.rect[3]
	or dcy > currentlv.rect[4]
	or dcx < currentlv.rect[1]
	or dcy < currentlv.rect[2]
	then
		sfx(4)
		return
	end
	
	local destcel=mget(
	 dcx,
	 dcy
	)
	
	if destcel == 18 then
	sfx(4)
		return
	end
	
	p.x=dcx
	p.y=dcy
	sfx(0)
	
	if destcel == 20 then
		load_next_lvl()
		return
	end
end

function load_next_lvl()
	lvindex=lvindex+1
	currentlv=lvls[lvindex]
	
	if currentlv == nil then
		endgame=true
		--music(-1)
		sfx(5)
		return
	end
	
	p.x=currentlv.spawn[1]
	p.y=currentlv.spawn[2]
end

function _draw() 
	draw_bg()
	
	if startgame then
		draw_text(
		 "saddly,",
		 128/2,
		 42
		)
		draw_text(
		 "you are trapped",
		 128/2,
		 52
		)
		draw_text(
		 "in the rainbow dungeon.",
		 128/2,
		 62
		)
		draw_text(
		 "press ⬆️,⬇️,⬅️ or ➡️",
		 128/2-8,
		 92
		)
		
		if btnp(⬆️)
		or btnp(⬇️)
		or btnp(⬅️)
		or btnp(➡️)
		then
			startgame=false
			--music(0)
		end
		
		return
	end
	
	if endgame then
		draw_text(
		 "you finally reached freedom",
		 128/2,
		 128/2-5
		)
		draw_text(
		 "well done!",
		 128/2,
		 128/2+5
		)
		return
	end
	
	local lv=currentlv
	
	local mx=lv.rect[1]
	local my=lv.rect[2]
	local msizex=lv.rect[3]-mx+1
	local msizey=lv.rect[4]-my+1
	local sx=0
	local sy=0
	local offsetx=(16-msizex)/2*8
	local offsety=(16-msizey)/2*8
	
	map(
	 mx,
	 my,
	 sx+offsetx,
	 sy+offsety,
	 msizex,
	 msizey
	)
	
	local px=p.x-lv.rect[1]
	local py=p.y-lv.rect[2]
	spr(
	 17,
	 px*8+offsetx,
	 py*8+offsety
	)
	
	draw_text(
		"❎ to retry",
		128/2-2,
		128-24
	)
	
	local cel=mget(p.x,p.y)
	printh(cel)
	if cel>0 and cel<6 then
		sspr(cel*8,0,8,8,56,0,16,16)
	end
end

function draw_text(str,x,y,al,extra,c1,c2)
    str = ""..str
    local al = al or 1
    local c1 = c1 or 7
    local c2 = c2 or 13

    if al == 1 then x -= #str * 2 - 1
    elseif al == 2 then x -= #str * 4 end

    y -= 3

    if extra then
        print(str,x,y+3,0)
        print(str,x-1,y+2,0)
        print(str,x+1,y+2,0)
        print(str,x-2,y+1,0)
        print(str,x+2,y+1,0)
        print(str,x-2,y,0)
        print(str,x+2,y,0)
        print(str,x-1,y-1,0)
        print(str,x+1,y-1,0)
        print(str,x,y-2,0)
    end

    print(str,x+1,y+1,c2)
    print(str,x-1,y+1,c2)
    print(str,x,y+2,c2)
    print(str,x+1,y,c1)
    print(str,x-1,y,c1)
    print(str,x,y+1,c1)
    print(str,x,y-1,c1)
    print(str,x,y,0)
end

t=0
function draw_bg()
 t+=0.02
 
 for i=0,1000 do
  local x,y=rnd(128),rnd(128)
  local c=(x/16+y/32+t)%6+8
  circfill(x,y,1,c)
 end
end
__gfx__
00000000333333333333333333333333333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000332333333323323333233233332332333323323300000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700333333333333333333333333333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000333333333333333333233333332332333323323300000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000333333333333333333333333333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700333333333333333333333333333333333333323300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333333333333333333333333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333333333333333333333333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333006006005555555511111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333066666605666666711111111156111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333065665605666666711111111156561110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333006666005666666711111111156565610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333006556005666666711111111156565610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333000660005666666711111111156565610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333006666005666666711111111156565610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333000660005777777711111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
aaaaaaaaaaaaabbbbbbbbbbbbbbbbccccccccccccccccdddddddddddddd8888888888888888889999999999999999aaaaaaaaaaaaaaaabbbbbbbbbbbbbbbcbcc
aaaaaaaaaaaaabbbbbbbbbbbbbbbccccccccccccccdcddddddddddddddd88888888888888888899999999999999a9aaaaaaaaaaaaaabbbbbbbbbbbbbbbcccccc
aaaaaaaaaababbbbbbbbbbbbbbbcccccccccccccccdddddddddddddddddd888888888888889899999999999999aaaaaaaaaaaaaaaabbbbbbbbbbbbbbbccccccc
aaaaaaaaabbbbbbbbbbbbbbbbbcccccccccccccccddddddddddddddddd88888888888888899999999999999999aaaaaaaaaaaaaaaabbbbbbbbbbbbbbbccbcccc
aaaaaaaabbbbbbbbbbbbbbbbbcccccccccccccccccddddddddddddddd88888888888888889999999999999999aaaa9aaaaaaaaaaaabbbbbbbbbbbbbbcccccccc
aaaaaaaaabbbbbbbbbbbbbbbbccccccccccccccccdddddddddddddddd8888888888888888989999999999999aaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbccccccc
aaaaaaaaaabbbbbbbbbbbbbcbbcccccccccccccccddddddddddddddd8d8888888888888889999999999999999aaaaaaaaaaaaaaabbbbbbbbbbbbbbbbcccccccc
aaaaaaaaabbbbbbbbbbbbbccccbcccccccccccccdddddddddddddd88888888888888888999999999999999999aaaaaaaaaaaaaabbbbbbbbbbbbbbbbccccccccc
aaaaaaaabbbbbbbbbbbbbbbccccccccccccccccccdddddddddddddd88888888888888899999999999999999999aaaaaaaaaaaaaabbbbbbbbbbbbbbbbcccccccc
aaaaaabbbbbbbbbbbbbbbbccccccccccccccccdcddddddddddddddd8d8888888888888999999999999999999aaaaaaaaaaaaaaaabbbbbbbbbbbbbbbccccccccc
aaaaabbbbbbbbbbbbbbbbbbccccccccccccccddddddddddddddddd888d88888888888999899999999999999aaaaaaaaaaaaaaabbbbbbbbbbbbbbbbcbcccccccc
aaaaaabbbbbbbbbbbbbbbbccccccccccccccccdddddddddddddddd888888888888888898999999999999999aaaaaaaaaaaaaabbbbbbbbbbbbbbbbccccccccccc
aaaaabbbbbbbbbbbbbbbbbccccccccccccccccdddddddddddddd8888888888888888899999999999999999aaaaaaaaaaaaaaaabbbbbbbbbbbbbbbccccccccccc
aaaabbbbbbbbbbbbbbbbbbcccccccccccccccdddddddddddddddd888888888888888899999999999999999aaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbcccccccccc
aaaaabbbbbbbbbbbbbbbcbbcccccccccccccdddddddddddddddd888888888888888899999999999999999aaaaaaaaaaaaaaaaabbbbbbbbbbbbbccbbccccccccc
aaabbbbbbbbbbbbbbbbccccccccccccccccdddddddddddddddddd8d88888888888889999999999999999aaaaaaaaaaaaaaaabbbbbbbbbbbbbbcccccccccccccc
aaabbbbbbbbbbbbbbbbbccccccccccccccddddddddddddddddddd8d88888888888899999999999999999aaaaaaaaaaaaaabbbbbbbbbbbbbbbbbccccccccccccc
aaabbbbbbbbbbbbbbbbccccccccccccccddddddddddddddddd8d8888888888888888999999999999999a9aaaaaaaaaaaabbbbbbbbbbbbbbbbcbccccccccccccc
aaabbbbbbbbbbbbbbbbbccccccccccccccddddddddddddddd888888888888888888899999999999999aaaaaaaaaaaaaaabbbbbbbbbbbbbbbcccccccccccccccc
aaabbbbbbbbbbbbbbbcccccccccccccccdcddddddddddddddd88888888888888888899999999999999aaaaaaaaaaaaaaaabbbbbbbbbbbbbbbcbccccccccccccc
aaaabbbbbbbbbbbbbbccccccccccccccdddcddddddddddddddd888888888888889999999999999999aaaaaaaaaaaaaaaaabbbbbbbbbbbbbbcbcccccccccccccc
aaabbbbbbbbbbbbbcccccccccccccccccddddddddddddddddd8888888888888899999999999999999aaaaaaaaaaaaaaaabbbbbbbbbbbbbbcccbccccccccccccc
aabbbbbbbbbbbbbccccccccccccccccdcdddddddddddddddd888d8888888888899999999999999999aaaaaaaaaaaaaaaabbbbbbbbbbbbbbbcbbccccccccccccc
abbbbbbbbbbbbbbcccccccccccccccddddddddddddddddddd88888888888888899999999999999999aaaaaaaaaaaaaaabbbbbbbbbbbbbbbcccbccccccccccccc
bbbbbbbbbbbbbbcbcccccccccccccccdcdddddddddddddd8d888888888888888999999999999999aaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbccccccccccccccccd
abbbbbbbbbbbbbcccccccccccccccccddddddddddddddd88888888888888888999999999999999aaaaaaaaaaaaaaabaabbbbbbbbbbbbbbbccccccccccccccccd
bbbbbbbbbbbbbbccccccccccccccccddddddddddddddddd8888888888888889999999999999999aaaaaaaaaaaaaabbbbbbbbbbbbbbbbbbccccccccccccccccdd
bbbbbbbbbbbbbbcccccccccccccccccddddddddddddddd8888888888888888899999999999999a9a9aaaaaaaaaaaabbbbbbbbbbbbbbbbbcccccccccccccccccd
bbbbbbbbbbbbbccccccccccc55555555555555555555555555555555555555555555555555555555555555555555555555555555bbbbbbbcccccccccccccccdd
bbbbbbbbbbbbcccccccccccc56666667566666675666666756666667566666675666666756666667566666675666666756666667bbbbbbcccccccccccccccddd
bbbbbbbbbbbbcccccccccccc56666667566666675666666756666667566666675666666756666667566666675666666756666667bbbcbbcccccccccccccccddd
bbbbbbbbbbbccccccccccccc56666667566666675666666756666667566666675666666756666667566666675666666756666667bbcccccccccccccccccccddd
bbbbbbbbbbbbcbcbcccccccc56666667566666675666666756666667566666675666666756666667566666675666666756666667bbbccbccccccccccccccdddd
bbbbbbbbbbbbcccccccccccc56666667566666675666666756666667566666675666666756666667566666675666666756666667bbbcccccccccccccccdcdddd
bbbbbbbbbbcbcccccccccccc56666667566666675666666756666667566666675666666756666667566666675666666756666667bcbbcccccccccccccccddddd
bbbbbbbbbccccccccccccccc57777777577777775777777757777777577777775777777757777777577777775777777757777777bbcccccccccccccccddddddd
bbbbbbbbcccccccccccccccc55555555111111113363363333333333333333333333333333333333333333333333333355555555bcccccccccccccccdddddddd
bbbbbbbbbcccbccccccccccc56666667111111113666666333333333333333333333333333333333333333333333333356666667bcccccccccccccccddcddddd
bbbbbbbbcccccccccccccccc56666667111111113656656333333333333333333333333333333333333333333333333356666667bccbbccccccccccddddddddd
bbbbbbbccccccccccccccccc56666667111111113366663333333333333333333333333333333333333333333333333356666667ccccccccccccccccdddddddd
bbbbbbbbcccccccccccccccc56666667111111113365563333333333333333333333333333333333333333333333333356666667bccccccccccccccccddddddd
bbbbbbbbcccccccccccccccc56666667111111113336633333333333333333333333333333333333333333333333333356666667bcccccccccccccdcdddddddd
bbbbbbbcccccccccccccccdd56666667111111113366663333333333333333333333333333333333333333333333333356666667cccccccccccccdddcddddddd
bbbbbcbcccccccccccccccdd57777777111111113336633333333333333333333333333333333333333333333333333357777777ccccccccccccccdddcdddddd
bbbbbcccccccccccccccccdd55555555555555555555555555555555555555555555555555555555555555553333333355555555ccccccccccccccddcddddddd
bbbbccccccccccccccccccdd56666667566666675666666756666667566666675666666756666667566666673333333356666667ccccccccccccccdddddddddd
bbbbbcbcccccccccccccddcd56666667566666675666666756666667566666675666666756666667566666673333333356666667cccccccccccccddddddddddd
bbbbcccccccccccccccddddd56666667566666675666666756666667566666675666666756666667566666673333333356666667ccccccccccccdddddddddddd
bbbcccccccccccccccdddddd56666667566666675666666756666667566666675666666756666667566666673333333356666667ccccccccccccdddddddddddd
bbbbccccccccccccccdddddd56666667566666675666666756666667566666675666666756666667566666673333333356666667ccccccccccdddddddddddddd
bcbccccccccccccccccddddd56666667566666675666666756666667566666675666666756666667566666673333333356666667cccccccccddddddddddddddd
bbccccccccccccccccdcdddd57777777577777775777777757777777577777775777777757777777577777773333333357777777ccccccccccdddddddddddddd
bbccbccccccccccccddddddd55555555333333333333333333333333333333333333333333333333333333333333333355555555cccccccccdcddddddddddddd
bcccccccccccccccdddcdddd56666667333333333333333333333333333333333333333333233233333333333333333356666667ccccccccdddddddddddddddd
cccccccccccccccccdcccddd56666667333333333333333333333333333333333333333333333333333333333333333356666667cccccccdddcddddddddddddd
cccccccccccccccccddddddd56666667333333333333333333333333333333333333333333333333333333333333333356666667ccccccccdccddddddddddddd
ccccbcccccccccccdddddddd56666667333333333333333333333333333333333333333333333333333333333333333356666667ccccccccccddddddddddddd8
cccccccccccccccddddddddd56666667333333333333333333333333333333333333333333333333333333333333333356666667ccccccddddddddddddddddd8
ccccccccccccccdddddddddd56666667333333333333333333333333333333333333333333333333333333333333333356666667cccccccdddddddddddddd8d8
cccccccccccccccddddddddd57777777333333333333333333333333333333333333333333333333333333333333333357777777ccccccddddddddddddddd888
ccccccccccccccdddddddddd55555555333333335555555555555555555555555555555555555555555555555555555555555555ccccccddddddddddddddd888
cccccccccccccddddddddddd56666667333333335666666756666667566666675666666756666667566666675666666756666667cccccdddddddddddddddd888
ccccccccccccdddddddddddd56666667333333335666666756666667566666675666666756666667566666675666666756666667cccccddddddddddddddd8888
ccccccccccccddcddddddddd56666667333333335666666756666667566666675666666756666667566666675666666756666667ccccdddddddddddddddd8888
cccccccccccddddddddddddd56666667333333335666666756666667566666675666666756666667566666675666666756666667cccddddddddddddddddd8888
ccccccccccccdddddddddddd56666667333333335666666756666667566666675666666756666667566666675666666756666667ccccdddddddddddddddd8888
cccccccccccccddddddddddd56666667333333335666666756666667566666675666666756666667566666675666666756666667ccddddddddddddddddd88888
ccccccccccccdddddddddddd57777777333333335777777757777777577777775777777757777777577777775777777757777777cddddddddddddddddd888888
ccccccccdcddcddddddddddd55555555333333333333333333333333333333333333333333333333333333333333333355555555ccdddddddddddddddd888888
cccccccddddddddddddddddd56666667333333333333333333233233333333333333333333333333333333333333333356666667cdcddddddddddddddd888888
ccccccccddddddddddddddd856666667333333333333333333333333333333333333333333333333333333333333333356666667ddddddddddddddd88d888888
ccccccccdddddddddddddddd56666667333333333333333333233333333333333333333333333333333333333333333356666667dddddddddddddd8888888888
cccccccccddddddddddddddd56666667333333333333333333333333333333333333333333333333333333333333333356666667ddddddddddddddd888888888
ccccccccccdddddddddddddd56666667333333333333333333333333333333333333333333333333333333333333333356666667ddddddddddddddd888888888
ccccccdcdddddddddddddddd56666667333333333333333333333333333333333333333333333333333333333333333356666667dddddddddddddd8888888888
cccccddddddddddddddddddd57777777333333333333333333333333333333333333333333333333333333333333333357777777ddddddddddddd88888888888
cccccdddddddddddddddd88d55555555555555555555555555555555555555555555555555555555555555553333333355555555dddddddddddd888888888888
ccccdddccddddddddddd888856666667566666675666666756666667566666675666666756666667566666673333333356666667dddddddddddd888888888888
cccccddcddddddddddd8888856666667566666675666666756666667566666675666666756666667566666673333333356666667dddddddddddd888888888888
ccccdddddddddddddddd888856666667566666675666666756666667566666675666666756666667566666673333333356666667ddddddddddd8888888888888
ccccddddddddddddddd8888856666667566666675666666756666667566666675666666756666667566666673333333356666667ddddddddddd8888888888888
ccddddddcdddddddddd8888856666667566666675666666756666667566666675666666756666667566666673333333356666667ddddddddddd8d88888888888
cdddddddddddddddddd8d88856666667566666675666666756666667566666675666666756666667566666673333333356666667dddddddddddd888888888888
ccdddddddddddddddd88888857777777577777775777777757777777577777775777777757777777577777773333333357777777ddddddddddd8888888888888
ccddddddddddddddd888888855555555111111113333333333333333333333335555555533333333333333333333333355555555ddddddddd888888888888888
cddddddddddddddddd88888856666667156111113333333333333333333333335666666733233233333333333333333356666667dddddddd8888888888888888
dddddddddddddddddd88888856666667156561113333333333333333333333335666666733333333333333333333333356666667dddddddd8888888888888889
ddddddddddddddddd888888856666667156565613333333333333333333333335666666733333333333333333333333356666667ddddddddd888888888888899
dddddddddddddddd888d888856666667156565613333333333333333333333335666666733333333333333333333333356666667ddddddd88888888888888899
ddddddddddddddd88888888856666667156565613333333333333333333333335666666733333333333333333333333356666667ddddd8888888888888888889
dddddddddddddd888888888856666667156565613333333333333333333333335666666733333333333333333333333356666667dddd88888888888888888888
ddddddddddddd888d888888857777777111111113333333333333333333333335777777733333333333333333333333357777777ddddd8888888888888888889
dddddddddddddd8d8888888855555555555555555555555555555555555555555555555555555555555555555555555555555555dddd88888888888888888899
ddddddddddddd888d888888856666667566666675666666756666667566666675666666756666667566666675666666756666667ddddd8888888888888888899
ddddddddddddd8888888d88856666667566666675666666756666667566666675666666756666667566666675666666756666667ddddd8888888888888889999
ddddddddddd888888888888856666667566666675666666756666667566666675666666756666667566666675666666756666667dddd88888888888888899999
dddddddddd8888888888888856666667566666675666666756666667566666675666666756666667566666675666666756666667dddd88888888888888889999
ddddddddddd888888888888856666667566666675666666756666667566666675666666756666667566666675666666756666667dddd88888888888888889999
dddddddddd8888888888888856666667566666675666666756666667566666675666666756666667566666675666666756666667ddd888888888888888899999
ddddddddd88888888888888857777777577777775777777757777777577777775777777757777777577777775777777757777777dddd88888888888889999999
ddddddddd8888888888888888999999999999999aaa977777aaaaaa777bb77bbbbb777b777c777c777c7c7ccccddddddddddddddddd888888888888899999999
dddddddd88888888888888888899999999999999aaa7000007aaaa700077007bbb700070007000700070707ccccdddddddddddddd88d88888888888889999999
ddddddddd888888888888888989999999999999aaa700707007aaad70770707bbb70707077d707707070707dcddddddddddddddd888888888888888889999999
dddddddddd88888888888889999999999999999aaa700070007aaaa70770707bbb70077007c707700770007ddddddddddddddd8d888888888888889998999999
ddddddddd88888888888888999999999999999aaaa700707007aaaa70770707bbb70707077c707707077707dddddddddddddd888888888888888888999999999
ddddddd8888888888888888899999999999999aaaad7000007daaab7077007dbbb707070007707707070007ddddddddddddddd88888888888888889899999999
ddddd8d88888888888888888999999999999999aaaad77777daaaabd7dd77dbbbbd7d7d777dd7dd7d7d777dddcdddddddddddddd8d8888888888888999999999
dddd888888888888888888989999999999999999aaaadddddaaaabbbdbbddbbbbbbdbdcdddccdccdcdcdddcdcdddddddddddddd8888888888888889999999999
ddddd88888888888888889999999999999999999aaaaaaaaaaaaaabbbbbbbbbbbbbbbbcbccccccccccccddddddddddddddddd8d8888888888888989999999999
dddddd888888888888888899999999999999aaaaaaaaaaaaaaababbbbbbbbbbbbbbbbccccccccccccccccddddddddddddddd8888888888888889999999999999
ddddd8888888888888888899999999999999aaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbccccccccccccccccdddddddddddddd88888888888888888999999999999
dddd8d888888888888888999999999999999aaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbccccccccccccccccddddddddddddddd88888888888888888999999999999
ddddd8d88888888888889999999999999999aaaaaaaaaaaaaaabbbbbbbbbbbbbbbbccccccccccccccccddddddddddddddddd8888888888888889999999999999
ddd88d888888888888899999999999999999aaaaaaaaaaaaaabbbbbbbbbbbbbbbcccccccccccccccccccdddddddddddddddd8888888888888899999999999999
dd888888888888888889999999999999999aaaaaaaaaaaaaaabbbbbbbbbbbbbbbccccccccccccccccccddddddddddddddd8d8888888888888989999999999999
ddd88888888888888899999999999999999aaaaaaaaaaaaaabbbbbbbbbbbbbbbbccccccccccccccccccddddcddddddddd8888888888888889999999999999999
ddd8888888888888899999999999999999aaaaaaaaaaaaaaabbbbbbbbbbbbbbbccccccccccccccccccdddddddddddddddd888888888888889999999999999999
dd8888888888888899999999999999999aaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbccccccccccccccccdddddddddddddddd8888888888888888999999999999999
d888888888888889999999999999999999aaaaaaaaaaaaabbbbbbbbbbbbbbbbbbccccccccccccccccddddddddddddddd8d888888888888889999999999999999
888888888888888999999999999999aaa9aaaaaaaaaaaaaababbbbbbbbbbbbbbccccccccccccccccddddddddddddddd88888888888888889999999999999999a
8888888888888888999999999999999a9aaaaaaaaaaaaaaaabbbbbbbbbbbbbbccccccccccccccccccddddddddddddd88888888888888888999999999999999aa
888888888888888999999999999999a9aaaaaaaaaaaaaaaabbbbbbbbbbbbbbbcccccccccccccccdcddddddddddddd8888888888888888899999999999999999a
88888888888888899999999999999aaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbcccccccccccccccdddddcddddddddddd8888888888888889899999999999999999
8888888888888888999999999999aaaa9aaaaaaaaaaaaaabbbbbbbbbbbbbbcccccccccccccccccddddddddddddddddd888888888888899999999999999999999
8888888888889998999999999999aaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbccccccccccccccccccddddddddddddddddd88888888888889999999999999999999a
888888888888999989999999999aaaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbccccccccccccccccdddddddddddddddddd888888888888999999999999999999aaa
8888888888888999999999999999aaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbcccccccccccccccccddddddddddddddddd888888888888899999899999999999aaaa
88888888888899999999999999999a9aaaaaaaaaaaaaabbbbbbbbbbbbbbccccbccccccccccccddddddddddddddddd88888888888888999999999999999999aaa

__map__
1212121212121212121200121212121212121200121212121200121212121212121212121212121200000000000000000000000000000000000000000000000000121212001212121212121212121212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1213101010101010101200121310020112121200121010131200121310101010100202120310051200000000000000000000000000000000000000000000000000121312001213101010101010101010101412000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212101200121012120101121200121410101200121012121212020502121012011200000000000000000000000000000000000000000000000000121012001212121212121212121212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1210101010100210101200121212010210121200121212121200121012021004121212121212011200000000000000000000000000000000000000000000000000121012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1210121212121212121200121212121214121200000000000000121012120410120303120312051200000000000000000000000000000000000000000000000000121012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1210100310101010101200121212121212121200000000000000121010100212120312120312031200000000000000000000000000000000000000000000000000121012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212101200000000000000000000000000000000121012121212051210101012101200000000000000000000000000000000000000000000000000121012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1214101010120210101200000000000000000000000000000000120312101012121205121212041200000000000000000000000000000000000000000000000000121412000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121200000000000000000000000000000000121012021210101010100310141200000000000000000000000000000000000000000000000000121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000001212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000001213040402020205120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000001212050102030102120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000001212030303020304120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000001212020102020305120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000001212030303030401120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000001212040305030514120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000001212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000121303030403031212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000120401050402031212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000120302040312121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000120202020303030504141200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000120303030312121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000120102040204041212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000120205030503011212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000015050180501b0502105026050290502a050110500c0500605002050000500305002050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001e00001b0501c0502405026050290500005021050200500005017050160500005000050000500005027050260502705001050280502905019050170500005000050000500c050000500c0500b0501505000050
00100000200502005020050200500000000000240502b0502b0502b0502c0502c0502a0502705027050000001f0501d050190501605015050140501205001050000001f0501e0501f0501e0501f0502705027050
001e00000405004050040500305002050020500305003050030500305002050020500405005050030500305003050030500305003050030500105001050010500205003050030500205002050030500305003050
000100000955009550095500955009550095500955009550055500555005550045500255000550005500955009550095500955009550095500955009550025500255002550025500155001550015500155000550
0006000019550195501955019550265502655026550265501a5501a5501a5501a5502b5502b5502b5502b5502b5502b5502b5502b550315503155031550315502b5502b550305503055030550305503055030550
001000001b050200502205023050230501b050200502205023050230500c050110501305014050140500c050110501305014050140501c050200502205023050230500c050130501a0501d0501f0501f00000000
__music__
02 03424344

