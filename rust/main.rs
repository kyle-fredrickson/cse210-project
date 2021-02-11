use std::env;

mod speck;

fn main()
{
    let args: Vec<String> = env::args().collect();
    std::process::exit(match args.len()
    {
        5 => {
                 let file_in = &args[1];
                 let key = &args[2];
                 let nonce = &args[3];
                 let file_out = &args[4];
                 0
             },
        _ => 1
    });
}