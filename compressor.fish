for f in art/*
   cwebp -q 90 $f -o cart/(string sub -s 5 -e -4 $f).webp
end

