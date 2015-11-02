--By Trey Reynolds

--This will return a unique number for each different positive integer vector of the same dimension.
--Some guy named Cantor did this first, but mine is any dimension, so suck it, Cantor.
--Maybe I'll make an inverse function some time.

local function unique(...)
	local n={...}
	local s,f,u=0,1,0
	for i=1,#n do
		s,f=s+n[i],f*i
		local v=1
		for j=1,i do
			v=v*(s+j-1)
		end
		u=u+v/f
	end
	return u
end
