use std::{
    env, fs,
    fs::File,
    io::{BufRead, BufReader},
    path::Path,
    iter::zip,
    process::exit,
};

use regex::{RegexBuilder};

// https://stackoverflow.com/questions/30801031
// Read a file and get an array of strings
fn file_lines(file_path: impl AsRef<Path>) -> Vec<String> {
    let f  = File::open(file_path).expect("cannot open file!");
    let br = BufReader::new(f);
    br.lines()
        .map(|l| l.expect("Could not parse line"))
        .map(|l| l.split_whitespace().collect::<Vec<_>>().join(""))
        .collect()
}

fn main() {
    let argv:Vec<String> = env::args().collect();
    if argv.len() != 3 {
        println!("usage: {} <path to wordlist> <path to haystack>",
                 &argv[0]);
        exit(2)
    }

    let wordlist_path = &argv[1];
    let haystack_path = &argv[2];

    // obtain needles
    let searched_words=file_lines(wordlist_path);
    let re_vec = searched_words
        .iter()
        .map(|needle|
             RegexBuilder::new(&format!(r"\b{}\b", needle))
             .case_insensitive(true)
             .build()
             .expect("frocio"))
        .collect::<Vec<_>>();

    // obtain haystack
    let file_contents = fs::read_to_string(haystack_path)
        .expect("stronzo");

    // brrrr
    for (re, w) in zip(re_vec.iter(), searched_words.iter()) {
        println!("{}: {}", w, re.find_iter(&file_contents).count());
    }
}
