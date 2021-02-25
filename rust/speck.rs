use std::iter::Iterator;
const ROUNDS: usize = 34usize;

pub fn add1(data : &mut [u64])
{
    let mut i = 0;
    loop
    {
        if data[i] == u64::MAX
        {
            data[i] = 0u64;
            i+=1;
        }
        else
        {
            data[i] += 1;
            break;
        }
        if i >= data.len() { break; }
    }
}

pub fn key_schedule(key: &[u64; 4]) -> [u64; ROUNDS]
{
    let mut key_schedule: [u64; ROUNDS] = [0; ROUNDS];
    let mut l: [u64; 3] = [key[1], key[2], key[3]];
    key_schedule[0] = key[0];

    for i in 0..(ROUNDS - 1)
    {
        l[i % 3] = (key_schedule[i].wrapping_add(l[i % 3].rotate_right(8))) ^ (i as u64);
        key_schedule[i + 1] = key_schedule[i].rotate_left(3) ^ l[i % 3];
    }

    key_schedule
}

fn enc_round(n: &mut [u64; 2], key: u64)
{
    let left: u64 = n[1];
    let right: u64 = n[0];

    n[1] = (left.rotate_right(8)).wrapping_add(right) ^ key;
    n[0] = right.rotate_left(3) ^ (left.rotate_right(8)).wrapping_add(right) ^ key;
}

pub fn speck_encrypt(pt: &[u64; 2], ct: &mut [u64; 2], keys: &[u64; ROUNDS])
{
    ct[0] = pt[0];
    ct[1] = pt[1];

    for i in 0..ROUNDS
    {
        enc_round(ct, keys[i]);
    }

}

pub fn speck_ctr(pt: &Vec<u64>, out: &mut Vec<u64>, key: &[u64; 4], nonce: &[u64; 2])
{
    let mut pad: [u64; 2] = [0u64; 2];
    let mut local_nonce: [u64; 2] = [nonce[0], nonce[1]];
    let keys: [u64; ROUNDS] = key_schedule(key);

    for i in (0..pt.len()).step_by(2)
    {
        speck_encrypt(&local_nonce, &mut pad, &keys);

        out[i] = pt[i] ^ pad[0];
        out[i + 1] = pt[i + 1] ^ pad[1];

        add1(&mut local_nonce)
    }
}