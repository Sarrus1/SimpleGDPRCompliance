#if defined _SimpleGDPRCompliance_included_
  #endinput
#endif
#define _SimpleGDPRCompliance_included_
 
/**
 * Checks if a client has accepted the GDPR rules.
 *
 * @param client    The client's index.
 * @return        	true if accepted, false if refused or not yet accepted.
 */
native bool ClientGDPRStatus(int client);