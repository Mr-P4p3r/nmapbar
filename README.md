# nmapbar
A Little program in Ruby that adds a progress bar to Nmap and enhances output, making it easier to identify open ports. 

![Alt Text](https://s3.gifyu.com/images/nmapbar.gif)



## Installation

Install tty-progressbar

```$ gem install tty-progressbar```


Install Pastel for colors =DD

```$ gem install pastel```


## Usage

With only two switches the use is very simple.

``` 
ruby nmapbar.rb -[switch] TARGET


-s          It will run a well-balanced scan, suitable for most situations,. 
            Nmap will run with theses flags enabled -sC -sV -n

-c          It will run a complete scan, but much slower. 
            Nmap will run with these flags enabled -A -p- -n
            


Example:
ruby nmapbar.rb -s 10.0.14.5

```
The result of every scan is saved in the same folder of the program, using as name the ip of the target.txt


