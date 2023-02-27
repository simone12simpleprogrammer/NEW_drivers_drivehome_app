import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import '../global/global.dart';
import '../infoHandler/app_info.dart';

class RatingTabPage extends StatefulWidget
{
  const RatingTabPage({Key? key}) : super(key: key);

  @override
  State<RatingTabPage> createState() => _RatingTabPageState();
}


class _RatingTabPageState extends State<RatingTabPage>
{
  double ratingsNumber = 0;

  @override
  void initState() {
    super.initState();

    getRatingsNumber();

  }

  getRatingsNumber()
  {
    setState(() {
      ratingsNumber = double.parse(Provider.of<AppInfo>(context,listen: false).driverAverageRatings);
    });

    setupRatingsTitle();
  }

  setupRatingsTitle()
  {
    if(ratingsNumber == 1)
    {
      setState(() {
        titleStarsRating = "Pessimo";
      });
    }

    if(ratingsNumber == 2)
    {
      setState(() {
        titleStarsRating = "Scarso";
      });
    }
    if(ratingsNumber == 3)
    {
      setState(() {
        titleStarsRating = "Così Così";
      });
    }
    if(ratingsNumber == 4)
    {
      setState(() {
        titleStarsRating = "Affidabile";
      });
    }
    if(ratingsNumber == 5)
    {
      setState(() {
        titleStarsRating = "Eccellente";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        backgroundColor: Colors.white24,
        child: Container(
          margin: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const SizedBox(height: 18,),

              const Text(
                "Feedback Ricevuti",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 18,),

              const Divider(height: 4, thickness: 4,color: Colors.black54,),

              const SizedBox(height: 30,),

              SmoothStarRating(
                rating: ratingsNumber,
                allowHalfRating: true,
                starCount: 5,
                color: Colors.green,
                borderColor: Colors.grey,
                size: 46,
              ),

              const SizedBox(height: 2,),

              Text(
                titleStarsRating,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.lightGreen,
                ),
              ),

              const SizedBox(height: 18,),


            ],
          ),
        ),
      ),
    );
  }
}

