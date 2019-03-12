module("MathUtils",package.seeall)

function InitModule()
    math.randomseed(tolua.gettime());
end

--使用Vector3对proto里定义的Vector3f进行赋值
function math.AssignProtoV3(pV3,uV3)
    pV3.x = uV3.x;
    pV3.y = uV3.y;
    pV3.z = uV3.z;
end

--proto里定义的Vector3f转换为Vector3
function math.ConvertProtoV3(pV3)
    return Vector3(pV3.x,pV3.y,pV3.z);
end

--计算XZ平面距离
function math.DistanceXZ(va,vb)
    return math.sqrt((va.x - vb.x)^2 + (va.z - vb.z)^2);
end

--贝塞尔曲线三次方公式
function math.BezierAt(a,b,c,d,t)
    local tv = 1 - t;
    return a*math.pow(tv,3) + b*3*t*math.pow(tv,2) + c*3*math.pow(t,2)*tv + d*math.pow(t,3);
end

--贝塞尔曲线二次方公式
function math.BezierQuadratic(a, b, c, t)
    local tv = 1 - t;
    return a * math.pow(tv, 2) + b * 2 * t * tv + c * math.pow(t, 2)
end

--掩码位运算 1左移N位和M做与运算,结果为0则M不包含第N位
function math.ContainsBitMask(m,n)
    return bit.band(m,bit.lshift(1,n)) ~= 0;
end

--掩码位运算 修改m第n位为1
function math.AddBitMask(m,n)
    return bit.bor(m,bit.lshift(1,n));
end

--掩码位运算 修改m第n位为0
function math.RemoveBitMask(m,n)
    return bit.band(m,bit.bnot(bit.lshift(1,n)));
end

--圆和圆是否相交 pa圆心1 pb圆心2 ra半径1 rb半径2
function math.IntersectCircleWithCircle(pa,pb,ra,rb)
    return Vector3.Distance(pa,pb) <= (ra + rb);
end

--圆和矩形是否相交 pa矩形中心 pb圆心 rt矩形右上角
function math.IntersectCircleWithBox(pa,pb,rt)
    --矩形中心指向圆心,并取绝对值
    local v = Vector2.New(math.abs(pa.x - pb.x),math.abs(pa.z - pb.z));
    --矩形中心指向右上角,并取绝对值
    local h = Vector2.New(math.abs(rt.x - pb.x),math.abs(rt.z - pb.z));
    local u = Vector2.New(math.max(0,v.x - h.x),math.max(0,v.y - h.y));
    return Vector2.Dot(u,u) <= 0.5;
end

--N阶贝塞尔曲线 德卡斯特里奥算法 De Casteljau’s Algorithm
function math.DeCasteljauBezier(ctrlPoints,N,iter,t)
    if N==1 then
        return (1 - t) * ctrlPoints[iter] + t * ctrlPoints[iter + 1];
    end
    return (1 - t) * math.DeCasteljauBezier(N - 1, iter, t) + t * math.DeCasteljauBezier(N - 1, iter + 1, t);
end

return MathUtils;