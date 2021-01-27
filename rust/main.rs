use std::env;

mod speck;

fn main()
{
    let args: Vec<String> = env::args().collect();
    std::process::exit(match args.len()
    {
        4 => {
                 let file_in = &args[0];
                 let key = &args[1];
                 let file_out = &args[2];
                 0
             },
        _ => 1
    });
}