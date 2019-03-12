function class(classname, super)  
    local superType = type(super)  
    local cls  
    --如果父类不是table则父类为空,暂不支持继承C++和C#对象
    if superType ~= "table" then  
        superType = nil  
        super = nil  
    end
    if super then  
        cls = {}
        setmetatable(cls, {__index = super})  
        cls.super = super  
    else
        cls = {ctor = function() end}  
    end

    cls.__cname = classname  
    cls.__ctype = 2
    cls.__index = cls  

    function cls.new(...)  
        local instance = setmetatable({}, cls)  
        instance.class = cls  
        instance:ctor(...)
        return instance
    end  

	return cls
end