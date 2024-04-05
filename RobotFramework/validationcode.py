def isReferenceNumberCorrect(referenceNumber):

    listedRefNumber = list(referenceNumber)
    #print(listedRefNumber)

    checknumber = listedRefNumber.pop()
    totalAmount = 0
    product = 1

    while (len(listedRefNumber) > 0):
        if (product == 1):
            product = 7
            totalAmount = totalAmount + (product * int(listedRefNumber.pop()))
        elif (product == 3):
            product = 1
            totalAmount = totalAmount + (product * int(listedRefNumber.pop()))
        else:
            product = 3
            totalAmount = totalAmount + (product * int(listedRefNumber.pop()))

    #print(totalAmount)
    result = (10 - (totalAmount % 10)) % 10

    if (result == int(checknumber)):
        return True

    return False

#hi
def isEqual(headerTotal, rowTotal, maxDifference):

    if ( abs(headerTotal-rowTotal) < maxDifference):
        return True
    return False

#This is letter mapping for different letters
LETTER_MAPPING = {
    'A': 10, 'B': 11, 'C': 12, 'D': 13, 'E': 14, 'F': 15, 'G': 16, 'H': 17, 'I': 18, 'J': 19, 'K': 20,
    'L': 21, 'M': 22, 'N': 23, 'O': 24, 'P': 25, 'Q': 26, 'R': 27, 'S': 28, 'T': 29, 'U': 30, 'V': 31,
    'W': 32, 'X': 33, 'Y': 34, 'Z': 35
}
 
def validate_iban(iban):
    iban = iban.replace(' ', '').upper()  # Remove spaces and convert to uppercase
    if len(iban) != 18:
        return False
   
    country_code = iban[:2]
    check_number = iban[2:4]
    base_part = iban[4:]
   
    # Check if check number and base part are digits
    if not check_number.isdigit() or not base_part.isdigit():
        return False
   
    # Move country code and check number to the end
    reordered_iban = base_part + country_code + check_number
   
    # Convert letters to numbers using the LETTER_MAPPING
    numeric_iban = ''.join(str(LETTER_MAPPING[char]) if char in LETTER_MAPPING else char for char in reordered_iban)
   
    # Perform modulus 97 operation
    if int(numeric_iban) % 97 != 1:
        return False, "näihin tekstinä mikä vika oli yhes esimerkis"
   
    return True

if __name__ == "__main__":
    ref = '1431432'
    val = isReferenceNumberCorrect(ref)
    print(val) 
