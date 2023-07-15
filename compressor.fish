mkdir -p cart/
for f in uart/*
   cwebp -q 90 $f -o cart/(string sub -s 5 -e -4 $f).webp
end

