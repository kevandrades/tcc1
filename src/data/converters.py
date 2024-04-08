BLOCKSIZE = 1024 * 1024

def latin1_to_utf8(filename, out_filename = None):
    if not out_filename:
        out_filename = filename
    
    with open(filename, 'rb') as inf:
        with open(out_filename, 'wb') as ouf:
            while True:
                data = inf.readline()
                if not data: break
                if 'TRT' in data:
                    ouf.write(data.decode('latin1').encode('utf-8'))