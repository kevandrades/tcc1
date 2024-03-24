BLOCKSIZE = 1024 * 1024

def latin1_to_utf8(filename, out_filename = None, blocksize = BLOCKSIZE):
    if not out_filename:
        out_filename = filename
    
    with open(filename, 'rb') as inf:
        with open(out_filename, 'wb') as ouf:
            while True:
                data = inf.read(blocksize)
                if not data: break
                ouf.write(data.decode('latin1').encode('utf-8'))