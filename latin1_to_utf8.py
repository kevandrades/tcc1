BLOCKSIZE = 1024*1024

filename = "data/tbl_fato_R.csv"
out_filename = "data/tbl_fato_R_utf8.csv"

with open(filename, 'rb') as inf:
    with open(out_filename, 'wb') as ouf:
        while True:
            data = inf.read(BLOCKSIZE)
            if not data: break
            ouf.write(data.decode('latin1').encode('utf-8'))