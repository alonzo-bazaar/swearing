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

        .collect()
}

// https://stackoverflow.com/questions/51257304
// Creating a sliding window iterator of slices of chars from a String
fn char_windows<'a>(src: &'a str, win_size: usize)
                    -> impl Iterator<Item = &'a str> {
    src.char_indices()
        .flat_map(move |(from, _)| {
            src[from ..].char_indices()
                .skip(win_size - 1)
                .next()
                .map(|(to, c)| {
                    &src[from .. from + to + c.len_utf8()]
                })
        })
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

    // obtain needle
    let searched_words=file_lines(wordlist_path);

    // obtain haystack
    let file_contents = fs::read_to_string(haystack_path)
        .expect("stronzo")
        .to_lowercase();

    let re_vec = searched_words
        .iter()
        .map(|needle|
             RegexBuilder::new(&format!(r"\b{}\b", needle))
             // .case_insensitive(true)
             .build()
             .expect("frocio"))
        .collect::<Vec<_>>();

    for (re, w) in zip(re_vec.iter(), searched_words.iter()) {
        println!("{}: {}", w, re.find_iter(&file_contents).count());
    }

    /*
    for w in searched_words.iter() {
        let wl = w.len();
        let c = file_contents
            .windows(wl+2)
            .filter(|s|
                    zip(w.iter(), s.iter().skip(1)).all(|(a, b)| a == b)
                    && (!s[0].is_alphabetic())
                    && (!s[wl+1].is_alphabetic()))
            .count();
        println!("{}: {}", w.iter().collect::<String>(), c);
    }
    */
}
