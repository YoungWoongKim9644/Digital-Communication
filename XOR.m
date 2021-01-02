function arr3 = XOR(arr1, arr2)
arr3 = arr1*arr2;
for y = 1:size(arr1,1)
    for x = 1:size(arr2,2)
        if arr3(y,x) >= 2
            arr3(y,x) = rem(arr3(y,x),2);
        end
    end
end

end
