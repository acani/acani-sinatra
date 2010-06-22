// users
{
   "_id" : "497ce96f395f2f052a494fd4", // user id
   "fb_id": "514417",
   "fblink": "http://www.facebook.com/mattdipasquale",
   "name": "Matt limit 15 c", // limit to 15 chars
   "headline": "headline: limit it to 50 chars. This string is 50", // limit to 50 chars
   "about": "about: limit to 130 chars. this about is 130 chars cause that's the way I do it. limit to 130 chars. this about is 130 chars caus", // limit to 130 chars
   "age": 25, // 13 - 300
   "height": 175, // stored in cm. entered in feet (1 - 9) & inches (0 - 12)
   "weight": 150, // stored in lbs (0 - 438)
   "ethnicity": "white", // options: Do Not Show, Asian, Black, Latino, Middle Eastern, Mixed, Native American, White, Other
   "distance": 2343, // in feet.
   "show_distance": "show", 
   "last_online": "2010-03-14T21:20:14+0000"
   "new_messages": {
      "data": [
         {
            "id": "123_514417_1234332", // uid_to__uid_from__msg_id
            "message": "hey what's up this is a message. limit it to ?? TBD",
            "created_time": "2010-06-11T01:06:19+0000"
         }
      ]
   }
},

// db.users.ensureIndex({"devices.id": 1});