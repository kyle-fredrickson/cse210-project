use std::convert::TryInto;
use std::env;
use std::fs::*;
use std::io::prelude::*;
use std::u64;

mod speck;

fn read_hex64(n: &String, out: &mut [u64])
{
    let len = n.len() / 16;
    for i in 0..len
    {
        let num = match u64::from_str_radix(&n[16 * (len - (i + 1))..16 * (len - (i + 1)) + 16], 16)
        {
            Ok(n) => n,
            Err(_) => panic!("Invalid hex string.")
        };
        out[i] = num;
    }
}

fn chunk64(bytes: &Vec<u8>, out: &mut Vec<u64>)
{
    let mut bytes_slice : [u8; 8];
    let mut num : u64;

    for i in 0..out.len()
    {
        bytes_slice = bytes[8 * i..8 * i + 8].try_into().expect("Wrong byte length.");
        num = u64::from_le_bytes(bytes_slice);
        out[i] = num;
    }
}

fn unchunk64(data: &Vec<u64>, out: &mut Vec<u8>)
{
    let mut arr : [u8; 8];
    for i in 0..data.len()
    {
        arr = data[i].to_le_bytes();
        for j in 0..8
        {
            out[8 * i + j] = arr[j];
        }
    }
}

fn main() -> Result<(), ()>
{
    let args: Vec<String> = env::args().collect();
    if args.len() != 5
    {
        Err(())
    }
    else
    {
        let file_in = &args[1];
        let key_str = &args[2];
        let nonce_str = &args[3];
        let file_out = &args[4];

        // let key: Vec<u64> = read_hex64(key_str);
        let mut key: [u64; 4] = [0; 4];
        read_hex64(key_str, &mut key);
        let mut nonce: [u64; 2] = [0; 2];
        read_hex64(nonce_str, &mut nonce);

        for i in 0..key.len()
        {
            println!("key {}: {:016x}", i, key[i]);
        }

        println!();

        let key_schedule: [u64; 34] = speck::key_schedule(&key);

        for i in 0..key_schedule.len()
        {
            println!("key schedule {}: {:016x}", i, key_schedule[i]);
        }

        println!();

        for i in 0..nonce.len()
        {
            println!("nonce {}: {:016x}", i, nonce[i]);
        }

        println!();

        // read file
        let fsize : i64 = match metadata(file_in)
        {
            Ok(md) => match md.len()
            {
                0 => 16i64,
                n => n as i64
            },
            Err(_) => panic!("Could not get file size.")
        };
        let padded_fsize = fsize + ((-fsize % 16) + 16);
        let mut buff = vec![0; padded_fsize as usize];

        let mut in_file = match File::open(file_in)
        {
            Ok(f) => f,
            Err(_) => panic!("Could not open input file.")
        };
        match in_file.read(&mut buff)
        {
            Ok(_) => drop(in_file),
            Err(_) => panic!("Could not read input file.")
        };

        // transform file in 64B blocks
        let mut pt: Vec<u64> = vec![0; buff.len() / 8];
        chunk64(&buff, &mut pt);
        drop(buff);

        println!("pt length: {}", padded_fsize / 8);

        for i in 0..pt.len()
        {
            println!("pt {}: {:016x}", i, pt[i]);
        }

        println!();

        let mut ct: Vec<u64> = vec![0; (padded_fsize / 8) as usize];
        speck::speck_ctr(&pt, &mut ct, &key, &nonce);

        let mut ct_bytes: Vec<u8> = vec![0; padded_fsize as usize];
        unchunk64(&ct, &mut ct_bytes);

        for i in 0..ct.len()
        {
            println!("ct {}: {:016x}", i, ct[i]);
        }

        drop(pt);
        drop(ct);

        let mut out_file = match File::open(file_out)
        {
            Ok(f) => f,
            Err(_) => match File::create(file_out)
            {
                Ok(f) => f,
                Err(_) => panic!("Could not create out file.")
            }
        };
        out_file.write_all(&ct_bytes);
        drop(out_file);

        Ok(())
    }
}