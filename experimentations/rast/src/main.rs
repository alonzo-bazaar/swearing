use std::{
    env, fs,
    path::Path,
    io::{BufRead, BufReader},
    iter::zip,
    process::exit,
};

// https://docs.rs/glob/latest/regex/
// https://docs.rs/glob/latest/glob/
use regex::Regex;
use glob::glob;

// https://docs.rs/rayon/latest/rayon/iter/index.html
use rayon::prelude::*;

fn path_is_file(path:impl AsRef<Path>) -> bool {
    // https://doc.rust-lang.org/std/fs/struct.FileType.html
    fs::metadata(path)
        .expect("e vaffanculo non si trova il file, mo come lo leggo?")
        .file_type()
        .is_file()
}

fn path_is_dir(path:impl AsRef<Path>) -> bool {
    // https://doc.rust-lang.org/std/fs/struct.FileType.html
    fs::metadata(path)
        .expect("e vaffanculo non si trova il file, mo come lo leggo?")
        .file_type()
        .is_dir()
}

fn main() {
    let argv:Vec<String> = env::args().collect();
    if argv.len() != 3 && argv.len() != 4 {
        eprintln!("usage: {} <path to wordlist> <path to haystack> [<glob>]",
                  &argv[0]);
        exit(2)
    }
    let wordlist_path = &argv[1];
    let haystack_path = &argv[2];
    if wordlist_path.is_empty() {
        eprintln!("path to word list cannot be empty string, asshole");
        exit(2)
    }
    if wordlist_path.is_empty() {
        eprintln!("path to haystack cannot be empty string, asshole");
        exit(2)
    }

    let glob_string = 
        if path_is_dir(haystack_path) {
            &format!("{}{}**/{}",
                     haystack_path,
                     if haystack_path.chars().last().expect("dhn") == '/' {""} else {"/"},
                     if argv.len() == 4 { &argv[3] }
                     else { "*" })
        } else {
            haystack_path
        };

    // https://stackoverflow.com/questions/30801031
    // Read a file and get an array of strings
    let needle_list=BufReader::new(fs::File::open(wordlist_path)
                                   .expect("oh rincoglionito! non si apre il file!"))
        .lines()
        .map(|l| l.expect("come t'ha fatto a fare sta cagata lo sai solo te"))
        .collect::<Vec<String>>();

    let needle_re_vec = needle_list
        .iter()
        .map(|needle| Regex::new(&format!(r"\b{}\b", needle))
             .expect("orcodio, manco na regex per bene sai farmi, puttana eva"))
        .collect::<Vec<Regex>>();


    // main glob loop
    // readapted from example at https://docs.rs/glob/latest/glob/fn.glob.html
    let files = glob(glob_string)
        .expect("oh stronzo! t'ha sbagliato a fare il glob diahane")
        .filter_map(Result::ok)
        .filter(|path| path_is_file(path))
        .collect::<Vec<_>>();

    let total_counts:Vec<u64> = files
        // .par_iter()
        .par_iter()
        .map(|file_path| fs::read_to_string(file_path)
             // .expect("ma non si riesce a leggere un cazzo")
             .unwrap_or("".to_string())
             .to_lowercase())
        .map(|file_contents|
             needle_re_vec
             .iter()
             .map(|re| re.find_iter(&file_contents).count() as u64)
             .collect::<Vec<_>>())
        .reduce(|| (0..needle_list.len()).map(|_| 0).collect::<Vec<u64>>(),
                |acc, curr_file_counts|
                zip(acc.iter(), curr_file_counts.iter())
                .map(|(a, b)| a + b)
                .collect::<Vec<u64>>())
        ;

    zip(needle_list.iter(), total_counts.iter())
        .for_each(|(a, b)| println!("{a}: {b}"));
}
