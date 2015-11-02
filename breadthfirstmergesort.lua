--A very quick sort function (takes O(n) extra space, though)
--Built specifically for use in LuaJIT. Is considerably faster than the built-in LuaJIT sort function.
--Could probably be improved a bit.
--Did you notice that every comment's first letter is in ascending alphabetical order? lelelele
local sort do
	local a
	local b={}--extra space

	local function lt(a,b)
		return a<b
	end

	function sort(table,comp)
		comp=comp or lt
		a=table
		local n=#a
		local c=1
		while c<n do
			local i=1
			while i<=n-c do
				local p=i
				local i0=i
				local j0=i+c
				local i1=j0-1
				local j1=i1+c<n and i1+c or n
				while i0<=i1 and j0<=j1 do
					if comp(a[j0],a[i0]) then
						b[p]=a[j0]
						j0=j0+1
					else
						b[p]=a[i0]
						i0=i0+1
					end
					p=p+1
				end
				for x=i0,i1 do
					b[p]=a[x]
					p=p+1
				end
				for y=j0,j1 do
					b[p]=a[y]
					p=p+1
				end
				i=i+2*c
			end
			for j=i,n do
				b[j]=a[j]
			end
			a,b=b,a
			c=2*c
		end
		if a~=table then
			for i=1,n do
				table[i]=a[i]
			end
		end
		return table
	end
end
