import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5FAFF),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 50),


                // Logo
                Center(
                  child: Container(
                    height: 90,
                    width: 90,

                    decoration: BoxDecoration(
                      color: const Color(0xff1E88E5),
                      borderRadius: BorderRadius.circular(25),
                    ),

                    child: const Icon(
                      Icons.water,
                      size: 55,
                      color: Colors.white,
                    ),
                  ),
                ),


                const SizedBox(height: 35),


                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff12355B),
                  ),
                ),


                const SizedBox(height: 8),


                const Text(
                  "Join AquaIntel and manage your aquarium smarter",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),


                const SizedBox(height: 35),



                // Name
                buildTextField(
                  controller: nameController,
                  hint: "Full Name",
                  icon: Icons.person_outline,
                ),


                const SizedBox(height: 18),


                // Email
                buildTextField(
                  controller: emailController,
                  hint: "Email Address",
                  icon: Icons.email_outlined,
                ),


                const SizedBox(height: 18),


                // Password
                buildTextField(
                  controller: passwordController,
                  hint: "Password",
                  icon: Icons.lock_outline,
                  obscure: hidePassword,

                  suffix: IconButton(
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),

                    onPressed: (){
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                ),



                const SizedBox(height: 18),



                // Confirm Password
                buildTextField(
                  controller: confirmPasswordController,
                  hint: "Confirm Password",
                  icon: Icons.lock_outline,
                  obscure: hideConfirmPassword,

                  suffix: IconButton(
                    icon: Icon(
                      hideConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),

                    onPressed: (){
                      setState(() {
                        hideConfirmPassword =
                            !hideConfirmPassword;
                      });
                    },
                  ),
                ),



                const SizedBox(height: 35),



                // Signup button
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(

                      backgroundColor:
                          const Color(0xff1E88E5),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),


                    onPressed: () {

                      if(passwordController.text !=
                          confirmPasswordController.text){

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content:
                            Text("Passwords do not match"),
                          ),
                        );

                        return;
                      }


                      // Later connect Firebase/MongoDB API here

                    },


                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                  ),
                ),



                const SizedBox(height: 25),



                // Login navigation

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    const Text(
                      "Already have an account? ",
                      style:
                      TextStyle(color: Colors.grey),
                    ),


                    GestureDetector(

                      onTap: (){

                        Navigator.pop(context);

                      },


                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color:
                          Color(0xff1E88E5),

                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),

                  ],
                ),



                const SizedBox(height: 30),


              ],
            ),
          ),
        ),
      ),
    );
  }




  Widget buildTextField({

    required TextEditingController controller,
    required String hint,
    required IconData icon,

    bool obscure = false,
    Widget? suffix,

  }){


    return TextField(

      controller: controller,

      obscureText: obscure,


      decoration: InputDecoration(

        hintText: hint,

        prefixIcon:
        Icon(icon,
          color: const Color(0xff1E88E5),
        ),


        suffixIcon: suffix,


        filled: true,

        fillColor: Colors.white,


        border:
        OutlineInputBorder(

          borderRadius:
          BorderRadius.circular(15),

          borderSide:
          BorderSide.none,

        ),


        focusedBorder:
        OutlineInputBorder(

          borderRadius:
          BorderRadius.circular(15),

          borderSide:
          const BorderSide(
            color:
            Color(0xff1E88E5),
            width: 2,
          ),
        ),

      ),

    );

  }

}