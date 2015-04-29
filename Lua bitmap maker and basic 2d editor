--By AxisAngle (Trey Reynolds)
--These are all my own algorithms, so they're  probably not very good.
--They work though, and they generally work well.
--Not very well commented, but look on line 32 for the bitmap file maker.
local canvas do
	canvas={}

	local char		=string.char
	local byte		=string.byte
	local sub		=string.sub
	local rep		=string.rep
	local concat	=table.concat
	local sort		=table.sort
	local open		=io.open
	local cos		=math.cos
	local sin		=math.sin

	local function tobytes(n)
		local r0=n%256
		n=(n-r0)/256
		local r1=n%256
		n=(n-r1)/256
		local r2=n%256
		n=(n-r2)/256
		local r3=n%256
		if r0==10 or r1==10 or r2==10 or r3==10 then
			error("Sorry! Not your fault, but the image could not be made (file has a 10 in it). Try a different image size.")
		end
		return char(r0,r1,r2,r3)
	end

	local function save(self,path)
		path=path or self.path
		local h=self.h
		local w=self.w
		local excess=-3*w%4
		local bytes=h*(3*w+excess)
		local lineend=rep('\0',excess)
		local bmp={
			"BM"									--Header
			..tobytes(54+bytes)						--Total file size.
			.."\0\0\0\0\54\0\0\0\40\0\0\0"			--No clue
			..tobytes(w)..tobytes(h)				--Width by height
			.."\1\0\24\0\0\0\0\0"					--Defines 24 bit color
			..tobytes(bytes)						--Total pixel byte length
			.."\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"	--Space that we don't use
		}
		for i=1,h do
			local row=self[i]
			for j=1,w do
				local pixel=row[j]
				local r=255*pixel.r+0.5
				local g=255*pixel.g+0.5
				local b=255*pixel.b+0.5
				r=r-r%1
				g=g-g%1
				b=b-b%1
				bmp[#bmp+1]=char(
					b<0 and 0 or 255<b and 255 or b==10 and 11 or b,
					g<0 and 0 or 255<g and 255 or g==10 and 11 or g,
					r<0 and 0 or 255<r and 255 or r==10 and 11 or r
				)
			end
			bmp[#bmp+1]=lineend
		end
		local data=concat(bmp)
		if path then
			local file=open(path,"w")
			file:write(data)
			file:close()
		end
		return data
	end

	local function drawpixel(self,r,g,b,x,y)
		local row=self[y]
		if row then
			local pixel=row[x]
			if pixel then
				pixel.r=r
				pixel.g=g
				pixel.b=b
			end
		end
	end

	--omg omg omgomgomgomgm I hate this so much.
	--I'll just do if statements..
	local function drawline(self,r,g,b,x0,y0,x1,y1)
		local s=(y1-y0)/(x1-x0)
		if s<1 then
			local min,max
			if x0<x1 then
				min=(x0<1 and 1 or (x0<self.w and x0 or self.w))
				max=(x1<1 and 1 or (x1<self.w and x1 or self.w))
			else
				min=(x1<1 and 1 or (x1<self.w and x1 or self.w))
				max=(x0<1 and 1 or (x0<self.w and x0 or self.w))
			end
			for i=min-min%1,max-max%1 do
				local j=y0+s*(i-x0)+0.5
				j=j-j%1
				if 0<j and j<=self.h then
					local pixel=self[j][i]
					pixel.r,pixel.g,pixel.b=r,g,b
				end
			end
		else
			s=(x1-x0)/(y1-y0)
			local min,max
			if y0<y1 then
				min=(y0<1 and 1 or (y0<self.h and y0 or self.h))
				max=(y1<1 and 1 or (y1<self.h and y1 or self.h))
			else
				min=(y1<1 and 1 or (y1<self.h and y1 or self.h))
				max=(y0<1 and 1 or (y0<self.h and y0 or self.h))
			end
			for j=min-min%1,max-max%1 do
				local i=x0+s*(j-y0)+0.5
				i=i-i%1
				if 0<i and i<=self.w then
					local pixel=self[j][i]
					pixel.r,pixel.g,pixel.b=r,g,b
				end
			end
		end
	end

	--It works surprisingly well considering I made this up on the spot.
	--It might even handle all cases.... lol...
	--I think it pretty much does. Like except for lines.
	local function polylines(poly,height)
		local lines={}
		local min,max=height,1
		for i=1,#poly do
			local a=poly[i]
			if a.y<min then min=a.y end
			if max<a.y then max=a.y end
			local b=poly[i%#poly+1]
			if a.y~=b.y then
				lines[#lines+1]={
					x0=a.x;
					y0=a.y;
					y1=b.y;
					is=(b.x-a.x)/(b.y-a.y);
				}
			end
		end
		min=min<1 and 1 or min
		max=height<max and height or max
		return lines,min-min%1,max+-max%1
	end

	local function linecrosses(lines,height,width)
		local crosses={}
		local dy=lines[#lines].y1-lines[#lines].y0
		for k=1,#lines do
			local line=lines[k]
			local newdy=line.y1-line.y0
			if (height~=line.y0 or dy*newdy<0) and (line.y0<=height and height<=line.y1 or line.y1<=height and height<=line.y0) then
				local cross=line.x0+line.is*(height-line.y0)+0.5
				cross=cross-cross%1
				crosses[#crosses+1]=cross<1 and 1 or width<cross and width or cross
			end
			dy=newdy
		end
		sort(crosses)
		return crosses
	end

	local function drawpoly(self,r,g,b,poly)
		local lines,min,max=polylines(poly,self.h)
		for j=min,max do
			local crosses=linecrosses(lines,j,self.w)
			for k=1,#crosses-1,2 do
				for i=crosses[k],crosses[k+1] do
					local pixel=self[j][i]
					pixel.r,pixel.g,pixel.b=r,g,b
				end
			end
		end
	end

	local function drawpolyfunc(self,colorfunction,poly)
		local lines,min,max=polylines(poly,self.h)
		for j=min,max do
			local crosses=linecrosses(lines,j,self.w)
			for k=1,#crosses-1,2 do
				for i=crosses[k],crosses[k+1] do
					local pixel=self[j][i]
					pixel.r,pixel.g,pixel.b=colorfunction(i,j)
				end
			end
		end
	end

	local function circlebounds(self,x,y,r)
		local lx,ly=x-r,y-r
		local ux,uy=x+r,y+r
		lx,ly=lx-lx%1,ly-ly%1
		ux,uy=ux+-ux%1,uy+-uy%1
		lx=lx<1 and 1 or self.w<lx and self.w or lx
		ly=ly<1 and 1 or self.h<ly and self.h or ly
		ux=ux<1 and 1 or self.w<ux and self.w or ux
		uy=uy<1 and 1 or self.h<uy and self.h or uy
		return lx,ux,ly,uy
	end

	local function drawcircle(self,r,g,b,x,y,d)
		local lx,ux,ly,uy=circlebounds(self,x,y,d)
		for j=ly,uy do
			for i=lx,ux do
				if (i-x)*(i-x)+(j-y)*(j-y)<d*d then
					local pixel=self[j][i]
					pixel.r,pixel.g,pixel.b=r,g,b
				end
			end
		end
	end

	local function drawcirclefunc(self,colorfunction,x,y,r)
		local r2=r*r
		local lx,ux,ly,uy=circlebounds(self,x,y,r)
		for j=ly,uy do
			for i=lx,ux do
				local rx,ry=i-x,j-y
				local d2=rx*rx+ry*ry
				if d2<=r2 then
					local pixel=self[j][i]
					pixel.r,pixel.g,pixel.b=colorfunction(i,j,rx,ry,d2^0.5)
				end
			end
		end
	end

	function canvas.new(w,h,r,g,b)
		if w==10 or h==10 then
			error("Sorry! 10 is not a width that is supported.")
		end
		r=r or 1
		g=g or 1
		b=b or 1
		local newcanvas={
			w=w;
			h=h;
			save=save;
			drawpixel=drawpixel;
			drawline=drawline;
			drawpoly=drawpoly;
			drawpolyfunc=drawpolyfunc;
			drawcircle=drawcircle;
			drawcirclefunc=drawcirclefunc;
		}
		for i=1,h do
			local row={}
			for j=1,w do
				row[j]={r=r,g=g,b=b,z=inf}
			end
			newcanvas[i]=row
		end
		return newcanvas
	end
end




--Make a new canvas
local c=canvas.new(400,300)

--Draw 10 circles
for i=1,10 do
	c:drawcircle(math.random(),math.random(),math.random(),math.random()*400,math.random()*300,math.random()*15+5)
end

--Draw 100 random quadralateral.
for i=1,100 do
	--This is the center
	local x,y=400*math.random(),300*math.random()
	--Generates a random r g and b
	--Generates 4 random points in an approximately square fassion. Draws the poly
	c:drawpoly(math.random(),math.random(),math.random(),{
		{x=x-8+math.random()*4,y=y-8+math.random()*4};
		{x=x+8+math.random()*4,y=y-8+math.random()*4};
		{x=x+8+math.random()*4,y=y+8+math.random()*4};
		{x=x-8+math.random()*4,y=y+8+math.random()*4};
	})
end

--Saves the file in the directory of the Lua script as example.bmp
c:save("example.bmp")
