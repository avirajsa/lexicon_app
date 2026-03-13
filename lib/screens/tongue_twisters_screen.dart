import 'package:flutter/material.dart';
import '../data/tongue_twisters.dart';
import '../widgets/twister_quote.dart';
import '../widgets/app_footer.dart';

class TongueTwistersScreen extends StatelessWidget {
  const TongueTwistersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(32, 100, 32, 40),
        itemCount: tongueTwisters.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Twisters",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  "Refine your speech",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 40),
                TwisterQuote(text: tongueTwisters[index]),
              ],
            );
          }
          if (index < tongueTwisters.length) {
            return TwisterQuote(text: tongueTwisters[index]);
          }
          
          return const Column(
            children: [
              SizedBox(height: 60),
              AppFooter(),
              SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}
