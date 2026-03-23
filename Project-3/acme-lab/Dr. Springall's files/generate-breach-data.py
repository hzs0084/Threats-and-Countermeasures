import base64
import random
import string

MITCH_BASE = 'superDUPER5tr0n9p@ssword-'
ALL_ASCII = string.ascii_letters + string.digits + string.punctuation

def generate_random(length=8):
    ret = random.choices(ALL_ASCII, k=length)
    return ''.join(ret)

def generate_diceware(count=4):
    words = []
    for k in range(count):
        index = random.randrange(7776)
        with open('diceware.txt') as handle:
            for i, line in enumerate(handle):
                if i == index:
                    words.append(line.strip().split(' ')[-1])
                    break

    return '_'.join(words)

print('Account: Alice Brown (alicebrown@)')
print('\tCurrent: ' + generate_random())
print('\tPrevious:')
for i in range(14):
    print('\t\t'+generate_random())
print('')

print('Account: Bob Barker (bobbarker@)')
print('\tCurrent: ' + generate_random(14))
print('\tPrevious:')
for i in range(5):
    print('\t\t'+generate_random(14))
print('')

print('Account: Claire Redfield (claireredfield@)')
print('\tCurrent: ' + generate_diceware())
print('\tPrevious:')
for i in range(6):
    print('\t\t'+generate_diceware())
print('')

print('Account: Eve Johnson (evejohnson@)')
print('\tCurrent: ' + generate_diceware(4))
print('\tPrevious:')
for i in range(8):
    print('\t\t'+generate_diceware(4))
print('')

print('Account: Mallory Martinez (mallorymartinez@)')
print('\tCurrent: ' + generate_diceware(7))
print('\tPrevious:')
for i in range(2):
    print('\t\t'+generate_diceware(7))
print('')

print('Account: Mitch Marcus (mitchmarcus@)')
pw = MITCH_BASE+'Jan2012'
print('\tCurrent: ' + base64.b64encode(pw.encode('ascii')).decode('ascii'))
print('\tPrevious:')
pw = MITCH_BASE+'Jan2011'
print('\t\t' + base64.b64encode(pw.encode('ascii')).decode('ascii'))
pw = MITCH_BASE+'Jan2010'
print('\t\t' + base64.b64encode(pw.encode('ascii')).decode('ascii'))
pw = MITCH_BASE+'Jul2009'
print('\t\t' + base64.b64encode(pw.encode('ascii')).decode('ascii'))
print('')


print('Account: Fong Ling (fongling@)')
print('\tCurrent: ' + generate_random(12))
print('\tPrevious:')
print('\t\tNone')
print('')
