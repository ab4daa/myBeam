//distance between p2 to line(p1,v1)
//https://onlinemschool.com/math/library/analytic_geometry/p_line/
float DistancePointLine(float3 p1, float3 v1, float3 p2)
{
    return length(cross(p1-p2, v1)) / length(v1);
}

// https://keisan.casio.com/exec/system/1223531414
float DistanceOfLines(float3 p1, float3 v1, float3 p2, float3 v2)
{
	float3 cp = cross(v1, v2);
	float cpl = length(cp);
	if(cpl != 0.0)
	{
		return abs( dot(cp, p2-p1) / cpl );
	}
	else
	{
		return length( cross(v1, p2-p1) ) / length(v1);
	}
}

float3x3 GetMatrixRotation(float4x3 in_matrix)
{
	return float3x3(in_matrix[0][0], in_matrix[0][1], in_matrix[0][2],
        in_matrix[1][0], in_matrix[1][1], in_matrix[1][2],
        in_matrix[2][0], in_matrix[2][1], in_matrix[2][2]);
}

float3 GetMatrixTranslation(float4x3 in_matrix)
{
	return float3(in_matrix[3][0], in_matrix[3][1], in_matrix[3][2]);
}

float3 GetMatrixScale(float4x3 in_matrix)
{	
	float x = length(float3(in_matrix[0][0], in_matrix[0][1], in_matrix[0][2]));
    float y = length(float3(in_matrix[1][0], in_matrix[1][1], in_matrix[1][2]));
    float z = length(float3(in_matrix[2][0], in_matrix[2][1], in_matrix[2][2]));
	return float3(x,y,z);
}

//distance between line(p1,v1) to line segment (start2, end2)
//https://en.wikipedia.org/wiki/Skew_lines#Distance
float DistanceLineLineSeg(float3 p1, float3 v1, float3 start2, float3 end2)
{
    float3 v2 = end2 - start2;
    float3 q1 = p1 + v1;
    float3 n = cross(v1, v2);
    //test for skewness
    float3x3 m = float3x3(p1-q1, q1-start2, start2-end2);
    if(determinant(m) != 0.0)
    {
        //skew        
        float3 n1 = cross(v1, n);
        //float3 n2 = cross(v2, n);
        //float3 c1 = p1 + v1 * (dot(start2-p1, n2) / dot(v1, n2));
        //float3 c2 = start2 + v2 * (dot(p1-start2, n1) / dot(v2, n1));
        float t = (dot(p1-start2, n1) / dot(v2, n1));
        return DistancePointLine(p1, v1, start2 + clamp(t, 0.0, 1.0) * v2);
    }
    else
    {
        //non skew
        if(length(n) != 0)
        {
            //non prarllel
            //check if start2 and end2 is on different side of the plane 
            //https://math.stackexchange.com/questions/214187/point-on-the-left-or-right-side-of-a-plane-in-3d-space
            //the plane is determined by three points: 
            float3 plane1 = p1;
            float3 plane2 = q1;
            float3 plane3 = p1 + n;
            float det1 = determinant( float3x3(plane2-plane1, plane3-plane1, start2-plane1) );
            float det2 = determinant( float3x3(plane2-plane1, plane3-plane1, end2-plane1) );
            if(det1 * det2 > 0.0)
            {
                //same side
                return min(DistancePointLine(p1, v1, start2), DistancePointLine(p1, v1, end2));
            }
            else
            {
                //different side => intersect
                return 0.0;
            }
        }
        else
        {
            //parallel
            return DistancePointLine(p1, v1, start2);
        }
    }
}
