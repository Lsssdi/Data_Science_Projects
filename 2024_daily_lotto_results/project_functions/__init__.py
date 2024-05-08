from bs4 import BeautifulSoup

def tag_text_clean(tag_text: str = None):
    
    if ":" in tag_text:
        tag_text = tag_text.split(":")[-1]    #obtain text value after colons if colon is present
        
    tag_text = tag_text.replace(",", "")  #remove commna in numbers
    tag_text = tag_text.replace("R", "")     #remove rand symbol in amounts
    tag_text = tag_text.strip()    #remove white space around text
    
    
    return tag_text


def lotto_results_html_to_dict(html_soup, date):
    
    draw_info = html_soup.find("div", class_="drawInfo")
    draw_number, machine_name, tickets_sold, _ = [ tag_text_clean(p.text) for p in draw_info.find_all("p") ]
    
    tickets_sold = int(tickets_sold)

    balls = [ int(li.text) for li in html_soup.find_all("li", class_="ball daily-lotto")]

    jackpot = tag_text_clean( html_soup.find("div", class_="jackpot daily-lotto").text )
    jackpot = float(jackpot)
    
    
    divisions_table = html_soup.find("table", class_="prizebreakdown")
    division_tags = [ divisions_table.find_all("tr")[i] for i in range(1,5) ]
    
    division_results = []

    for division in division_tags:
        div_prize, div_winners = [ float( tag_text_clean(td.text)) for td in division.find_all("td")   ][2:4]
        division_results.append( (div_winners, div_prize) )
        
    total_sales = float(tag_text_clean(divisions_table.find_all("tr")[-1].text))
    
    total_winners, total_winnings = [ tag_text_clean(td.text) for td in divisions_table.find_all("tr")[-2].find_all("td")][-2:]
    total_winners, total_winnings = int(total_winners), float(total_winnings)
      
    lotto_result_dict = {
        "draw_number":draw_number,
        "date":date,
        "machine_name":machine_name,
         "N1": balls[0],
         "N2": balls[1],
         "N3": balls[2],
         "N4": balls[3],
         "N5": balls[4],
         "tickets_sold":tickets_sold,
         "jackpot":jackpot,
         "div1_wniners": int( division_results[0][0]),
         "div1_prize": division_results[0][1],
         "div2_wniners": int( division_results[1][0]),
         "div2_prize": division_results[1][1],
         "div3_wniners": int( division_results[2][0]),
         "div3_prize": division_results[2][1],
         "div4_wniners": int( division_results[3][0]),
         "div4_prize": division_results[3][1],
        "total_sales": total_sales,
        "total_winners":total_winners,
        "total_winnings":total_winnings
        
    }
    
    return lotto_result_dict
